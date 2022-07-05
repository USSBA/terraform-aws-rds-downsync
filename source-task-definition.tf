resource "aws_cloudwatch_log_group" "source" {
  name = "${var.source_prefix}-${var.database}-db-dump"
}

resource "aws_ecs_task_definition" "source" {
  family                   = "${var.source_prefix}-${var.database}-db-dump"
  execution_role_arn       = aws_iam_role.source_exec.arn
  task_role_arn            = aws_iam_role.source_task.arn
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  requires_compatibilities = ["FARGATE"]
  container_definitions = jsonencode([
    {
      name      = "${var.source_prefix}-${var.database}-db-dump"
      image     = "public.ecr.aws/ussba/terraform-aws-rds-downsync:${var.image_tag}"
      cpu       = var.cpu
      memory    = var.memory
      essential = true
      environment = [
        { name = "DBPORT", value = tostring(var.source_db_port) },
        { name = "DBHOST", value = var.source_db_host },
        { name = "SOURCE_RDS_IDENTIFIER", value = var.source_rds_identifier },
        { name = "SQL_CLIENT", value = var.sql_client },
        #{ name = "S3_BUCKET", value = var.source_bucket }
        { name = "SOURCE_BUCKET", value = aws_s3_bucket.downsync.id },
        { name = "SCRUB_BUCKET", value = aws_s3_bucket.scrub_scripts.id },
      ]
      secrets = var.source_container_secrets
      command = ["/usr/local/bin/sync_dump.sh"]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "${var.source_prefix}-${var.database}-db-dump"
          awslogs-region        = data.aws_region.account.name
          awslogs-stream-prefix = "${var.source_prefix}-${var.database}-db-dump"
        }
      }
    }
  ])
}


# ECS Execution

data "aws_iam_policy_document" "source_exec" {
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
      for x in var.source_container_secrets : x.valueFrom
    ]
  }
  statement {
    actions = [
      "logs:*",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "source_exec" {
  name = "${var.source_prefix}-${var.database}-db-dump-exec"

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

resource "aws_iam_policy" "source_exec" {
  name   = "${var.source_prefix}-${var.database}-db-dump-exec"
  path   = "/"
  policy = data.aws_iam_policy_document.source_exec.json
}

resource "aws_iam_role_policy_attachment" "source_exec" {
  role       = aws_iam_role.source_exec.name
  policy_arn = aws_iam_policy.source_exec.arn
}

# Task Role

data "aws_iam_policy_document" "source_task" {
  #statement {
  #  sid       = "snsPublish"
  #  actions   = ["sns:Publish"]
  #  # figure this out
  #  resources = ["${local.prefix_sns}sba-notification-framework-*"]
  #}
  statement {
    actions = [
      "s3:ListBucket",
    ]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.downsync.id}"
    ]
  }
  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:ListMultipartUploadParts",
      "s3:AbortMultipartUpload",
    ]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.downsync.id}/${var.source_rds_identifier}/*"
    ]
  }
}

resource "aws_iam_role" "source_task" {
  name = "${var.source_prefix}-${var.database}-db-dump-task"

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

resource "aws_iam_policy" "source_task" {
  name   = "${var.source_prefix}-${var.database}-db-dump-task"
  path   = "/"
  policy = data.aws_iam_policy_document.source_task.json
}

resource "aws_iam_role_policy_attachment" "source_task" {
  role       = aws_iam_role.source_task.name
  policy_arn = aws_iam_policy.source_task.arn
}
