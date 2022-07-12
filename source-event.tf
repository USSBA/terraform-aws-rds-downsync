resource "aws_cloudwatch_event_rule" "source" {
  name                = "${var.prefix}-${var.source_rds_identifier}-downsync"
  schedule_expression = var.source_schedule
  is_enabled          = true
}

resource "aws_cloudwatch_event_target" "source" {
  rule      = aws_cloudwatch_event_rule.source.name
  target_id = "${var.prefix}-${var.source_rds_identifier}-downsync"
  arn       = "arn:aws:ecs:${data.aws_region.account.name}:${data.aws_caller_identity.account.account_id}:cluster/${var.source_ecs_cluster}"
  role_arn  = aws_iam_role.source.arn

  ecs_target {
    launch_type         = "FARGATE"
    task_count          = 1
    task_definition_arn = aws_ecs_task_definition.source.arn

    network_configuration {
      subnets          = var.source_subnets
      security_groups  = [aws_security_group.source.id]
      assign_public_ip = false
    }
  }
}
resource "aws_iam_role" "source" {
  name = "${var.prefix}-${var.source_rds_identifier}-event-downsync"

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
  name = "${var.prefix}-${var.source_rds_identifier}-event-downsync"
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
