resource "aws_security_group" "source" {
  name        = "${var.prefix}-${var.database}-downsync"
  description = "Source security group for ${var.database}"
  vpc_id      = data.aws_subnet.source.vpc_id
}

resource "aws_security_group_rule" "source_egress" {
  type              = "egress"
  from_port         = var.source_db_port
  to_port           = var.source_db_port
  security_group_id = aws_security_group.source.id
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

resource "aws_security_group_rule" "source_egress_http" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  security_group_id = aws_security_group.source.id
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

resource "aws_security_group_rule" "source_egress_https" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  security_group_id = aws_security_group.source.id
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

resource "aws_security_group_rule" "source_ingress" {
  # if we have time investigate cluster and db instance
  for_each = toset(try(data.aws_rds_cluster.source[0].vpc_security_group_ids, data.aws_db_instance.source[0].vpc_security_groups))

  type                     = "ingress"
  security_group_id        = aws_security_group.source.id
  source_security_group_id = each.value
  from_port                = var.source_db_port
  to_port                  = var.source_db_port
  protocol                 = "tcp"
}
