resource "aws_cloudwatch_event_rule" "source" {
  name = "${var.source_prefix}-${var.database}-downsync"
  schedule_expression = var.source_schedule
  is_enabled = true
}

resource "aws_cloudwatch_event_target" "source" {
  rule = aws_cloudwatch_event_rule.source.name
  target_id = "${var.source_prefix}-${var.database}-downsync"
  arn = var.ecs_cluster
  role_arn = aws_iam_role.source.arn

  ecs_target {
    launch_type = "FARGATE"
    task_count = 1
    task_definition_arn = # aws_ecs_task_definition.downsync_create.arn

    network_configuration {
      subnets = var.source_subnets
      security_groups = var.source_security_groups
      assign_public_ip = false
    }
  }
}
resource "aws_iam_role" "source" {
  name = "${var.source_prefix}-event-downsync"

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

resource "aws_iam_role_policy" "source" {
  name = "${var.source_prefix}-event-downsync"
  role = aws_iam_role.source.id

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
