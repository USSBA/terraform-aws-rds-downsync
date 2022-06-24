# default variables
variable "region" {
  type = string
  description = "Required; AWS Region the source and restore tasks run in."
}
variable "source_prefix" {
  type = string
  description = "Required; Prefix for the source environment where the db dump will be performed."
  default = ""
}
variable "target_prefix" {
  type = string
  description = "Required; Prefix for the target environment where the db restore will be performed."
  default = ""
}
#variable "databases" {
#  type = list(string)
#  description = "Reqired; List of RDS Identifiers that need to be downsynced."
#  default = []
#}
variable "rds_identifier" {
  type = string
  description = "Reqired; RDS Identifier that need to be downsynced."
}

# s3 bucket variables
variable "source_bucket" {
  type = string
  description = "Required; Source bucket where the source database dumps are stored."
}
#variable "create_buckets" {
#  type = bool
#  description = "Optional; Whether or not to create downsync and scrub script buckets."
#  default = true
#}
#variable "downsync_bucket_name" {
#  type        = string
#  description = "Required; Bucket name for the bucket that will contain DB dumps."
#}
#variable "scrub_bucket_name" {
#  type        = string
#  description = "Optional; Bucket name for the bucket that will contain DB scrub scripts."
#}
#variable "scrub_disabled" {
#  type = bool
#  description = "Optional; Set to false if database scrubbing is not required."
#  default = true
#}

# cloudwatch event variables

# source variables
variable "source_schedule" {
  type = string
  description = "Required; Cron schedule expression for when the downsync database dumps should be run. Expects format cron(0 7 ? * SAT *)"
  default = ""
}

# ecs variables

# source ecs variables
variable "source_cluster" {
  type = string
  description = "Required; Name of the ecs cluster that the db dump will be performed."
  default = ""
}
variable "source_subnets" {
  type = list(string)
  description = "Required; List of private subnets that the db dump will be performed from."
  default = ""
}
variable "source_security_groups" {
  type = list(string)
  description = "Required; List of security groups that will be attached to the db dump task."
  default = ""
}
variable "image_tag" {
  type = string
  description = "Versioned image tag used by the RDS Downsync Module. This image is maintained and supported by the USSBA. Image tag matches the version of the module."
}

# generic ecs variables consistent across environments
variable "cpu" {
  type = number
  description = "Optional; vCPU that is assigned to the task definition. Defaults to 256."
  default = 256
}
variable "memory" {
  type = number
  description = "Optional; Memory that is assigned to the task definition. Defaults to 512."
  default = 512
}
