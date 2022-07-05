resource "aws_cloudwatch_event_rule" "target" {
  name       = "${var.source_prefix}-${var.database}-restore"
  is_enabled = true

  event_pattern = <<EOF
{
  "detail-type": [
    "AWS API Call via CloudTrail"
  ],
  "source": [
    "aws.s3"
  ],
  "detail": {
    "eventSource": [
      "s3.amazonaws.com"
    ],
    "eventName": [
      "PutObject",
      "CompleteMultipartUpload"
    ],
    "requestParameters": {
      "bucketName": [
        ${aws_s3_bucket.downsync.id}
      ],
      "key": [
        "${var.source_rds_identifier}/db.tar"
      ]
    }
  }
}
EOF
}

resource "aws_cloudwatch_event_target" "target" {
  rule      = aws_cloudwatch_event_rule.target.name
  target_id = "${var.source_prefix}-${var.database}-restore"
  arn       = "arn:aws:ecs:${data.aws_region.account.name}:${data.aws_caller_identity.account.account_id}:cluster/${var.target_ecs_cluster}"
  role_arn  = aws_iam_role.target.arn

  ecs_target {
    launch_type         = "FARGATE"
    task_count          = 1
    task_definition_arn = aws_ecs_task_definition.target.arn

    network_configuration {
      subnets          = var.target_subnets
      security_groups  = [aws_security_group.target.id]
      assign_public_ip = false
    }
  }
}
resource "aws_iam_role" "target" {
  name = "${var.source_prefix}-${var.database}-event-restore"

  assume_role_policy = <<DOC
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
DOC
}

resource "aws_iam_role_policy" "target" {
  name = "${var.source_prefix}-${var.database}-event-restore"
  role = aws_iam_role.target.id

  policy = <<DOC
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "iam:PassRole",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "ecs:RunTask",
      "Resource": "*"
    }
  ]
}
DOC
}
