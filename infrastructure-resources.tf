data "aws_region" "account" {}

data "aws_caller_identity" "account" {}

data "aws_subnet" "source" {
  id = var.source_subnets[0]
}

# rds cluster
data "aws_rds_cluster" "source" {
  count              = var.rds_identifier_type == "cluster" ? 1 : 0
  cluster_identifier = var.source_rds_identifier
}

data "aws_db_instance" "source" {
  count                  = var.rds_identifier_type == "instance" ? 1 : 0
  db_instance_identifier = var.source_rds_identifier
}

data "aws_rds_cluster" "target" {
  count              = var.rds_identifier_type == "cluster" ? 1 : 0
  cluster_identifier = var.target_rds_identifier
}

data "aws_db_instance" "target" {
  count                  = var.rds_identifier_type == "instance" ? 1 : 0
  db_instance_identifier = var.target_rds_identifier
}
