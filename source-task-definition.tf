variable "image_tag" {
  description = "image tag for downsync_restore. default is latest"
  default     = var.image_tag
}

resource "aws_cloudwatch_log_group" "source" {
  name = "${var.source_prefix}-${var.database}-db-dump"
}

#locals {
#  container_environment = {
#    PGUSER                  = "sbaonemaster"
#    PGDATABASE              = "sbaone_prod"
#    PGHOST                  = "stg-certify-rds.cyy8xym5djtg.us-east-1.rds.amazonaws.com"
#    RDS_INSTANCE_IDENTIFIER = "stg-certify-rds"
#    TARGET_BUCKET           = "certify-db-downsync"
#  }
#  container_secrets_parameterstore = {
#    PGPASSWORD = "stg/certify/rds/password"
#  }
#}

resource "aws_ecs_task_definition" "source" {
  family = "${var.source_prefix}-${var.database}-db-dump"
  execution_role_arn       = aws_iam_role.source_exec.arn
  task_role_arn            = aws_iam_role.source_task.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  container_definitions = jsonencode([
    {
      name        = "${var.source_prefix}-${var.database}-db-dump"
      image       = "public.ecr.aws/ussba/terraform-aws-rds-downsync:${var.image_tag}"
      cpu         = var.cpu
      memory      = var.memory
      essential   = true
      environment = [for k, v in local.container_environment : { name = k, value = v }]
      secrets     = [for k, v in local.container_secrets_parameterstore : { name = k, valueFrom = "${local.prefix_parameter_store}/${v}" }]
      #entrypoint  = ["/scripts/entrypoint.restore.sh"]
      #command     = ["/scripts/certify/stg_restore.sh"]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "${var.source_prefix}-${var.database}-db-dump"
          awslogs-region        = var.region
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
      "ecr:*",
    ]
    resources = ["*"]
  }
  statement {
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
    ]
    # maybe?
    resources = ["${local.prefix_parameter_store}/${var.source_secrets}"]
    # just for reference
    resources = ["${local.prefix_parameter_store}/stg/certify/rds/password"]
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
  statement {
    sid       = "snsPublish"
    actions   = ["sns:Publish"]
    # figure this out
    resources = ["${local.prefix_sns}sba-notification-framework-*"]
  }
  statement {
    actions = [
      "s3:ListBucket",
    ]
    resources = [
      "arn:aws:s3:::${var.source_bucket}"
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
      "arn:aws:s3:::${var.source_bucket}/${var.rds_identifier}/*"
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
