resource "aws_cloudwatch_log_group" "target" {
  name = "${var.prefix}-${var.database}-db-restore"
}

locals {
  base_environment = [
    { name = "DBPORT", value = tostring(var.target_db_port) },
    { name = "DBHOST", value = var.target_db_host },
    { name = "TARGET_RDS_IDENTIFIER", value = var.target_rds_identifier },
    { name = "SOURCE_RDS_IDENTIFIER", value = var.source_rds_identifier },
    { name = "SQL_CLIENT", value = var.sql_client },
    { name = "SOURCE_BUCKET", value = aws_s3_bucket.downsync.id },
    { name = "SCRUB_BUCKET", value = aws_s3_bucket.scrub_scripts.id },
  ]
  optional_environment = [
    length(var.scrub_scripts) == 0 ? {} : { name = "SCRUB_SCRIPTS", value = join(" ", var.scrub_scripts) },
  ]
}
resource "aws_ecs_task_definition" "target" {
  family                   = "${var.prefix}-${var.database}-db-restore"
  execution_role_arn       = aws_iam_role.target_exec.arn
  task_role_arn            = aws_iam_role.target_task.arn
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  requires_compatibilities = ["FARGATE"]
  container_definitions = jsonencode([
    {
      name        = "${var.prefix}-${var.database}-db-restore"
      image       = "public.ecr.aws/ussba/terraform-aws-rds-downsync:${var.image_tag}"
      cpu         = var.cpu
      memory      = var.memory
      essential   = true
      environment = [for k in concat(local.base_environment, local.optional_environment) : k if try(k.name, null) != null]
      secrets     = var.target_container_secrets
      command     = ["/usr/local/bin/sync_restore.sh"]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "${var.prefix}-${var.database}-db-restore"
          awslogs-region        = data.aws_region.account.name
          awslogs-stream-prefix = "${var.prefix}-${var.database}-db-restore"
        }
      }
    }
  ])
}


# ECS Execution

data "aws_iam_policy_document" "target_exec" {
  statement {
    actions = [
      "ecr-public:*",
    ]
    resources = ["*"]
  }
  statement {
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
    ]
    resources = [
      for x in var.target_container_secrets : x.valueFrom
    ]
  }
  statement {
    actions = [
      "logs:*",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "target_exec" {
  name = "${var.prefix}-${var.database}-db-restore-exec"

  assume_role_policy = jsonencode({
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = ["ecs.amazonaws.com", "ecs-tasks.amazonaws.com"]
        }
      }
    ]
    Version = "2008-10-17"
  })
}

resource "aws_iam_policy" "target_exec" {
  name   = "${var.prefix}-${var.database}-db-restore-exec"
  path   = "/"
  policy = data.aws_iam_policy_document.target_exec.json
}

resource "aws_iam_role_policy_attachment" "target_exec" {
  role       = aws_iam_role.target_exec.name
  policy_arn = aws_iam_policy.target_exec.arn
}

# Task Role

data "aws_iam_policy_document" "target_task" {
  statement {
    actions = [
      "s3:ListBucket",
    ]
    resources = concat(
      ["arn:aws:s3:::${aws_s3_bucket.downsync.id}"],
      var.scrub_enabled ? ["arn:aws:s3:::${aws_s3_bucket.scrub_scripts.id}"] : []
    )
  }
  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:ListMultipartUploadParts",
      "s3:AbortMultipartUpload",
    ]
    resources = concat(
      ["arn:aws:s3:::${aws_s3_bucket.downsync.id}/${var.source_rds_identifier}/*"],
      var.scrub_enabled ? ["arn:aws:s3:::${aws_s3_bucket.scrub_scripts.id}/*"] : []
    )
  }
}

resource "aws_iam_role" "target_task" {
  name = "${var.prefix}-${var.database}-db-restore-task"

  assume_role_policy = jsonencode({
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = ["ecs.amazonaws.com", "ecs-tasks.amazonaws.com"]
        }
      }
    ]
    Version = "2008-10-17"
  })
}

resource "aws_iam_policy" "target_task" {
  name   = "${var.prefix}-${var.database}-db-target-task"
  path   = "/"
  policy = data.aws_iam_policy_document.target_task.json
}

resource "aws_iam_role_policy_attachment" "target_task" {
  role       = aws_iam_role.target_task.name
  policy_arn = aws_iam_policy.target_task.arn
}
