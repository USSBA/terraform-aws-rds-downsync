# default variables
variable "prefix" {
  type        = string
  description = "Required; Prefix for the source environment where the db dump will be performed."
  default     = ""
}
variable "scrub_enabled" {
  type        = bool
  description = "Optional; Set to true if database scrubbing is required. Default is false."
  default     = false
}

# db variables
variable "rds_identifier_type" {
  type        = string
  description = "Optional; RDS instance type needs to be one of 'cluster' or 'instance'. Defaults to instance."
  default     = "instance"
}
variable "sql_client" {
  type        = string
  description = "Required; A SQL client version. Must be one of the following: postgresql-client-10 | postgresql-client-11 | postgresql-client-12 | mysql-client."
}

# source db variables
variable "database" {
  type        = string
  description = "Required; A single RDS Identifier that needs to be downsynced."
}
variable "source_rds_identifier" {
  type        = string
  description = "Required; Source RDS Identifier that will be dumped and stored in s3 for a downsync."
}
variable "source_db_port" {
  type        = number
  description = "Required; The port for the SQL client. Example: 5432"
}
variable "source_db_host" {
  type        = string
  description = "Required; Source Host of the database. This can be a FQDN or the ARN of the database."
}

# target db variables
variable "target_rds_identifier" {
  type        = string
  description = "Required; Target RDS Identifier that will be restored from the source_rds_identifier."
}
variable "target_db_port" {
  type        = number
  description = "Required; The port for the SQL client. Example: 5432"
}
variable "target_db_host" {
  type        = string
  description = "Required; Target Host of the database. This can be a FQDN or the ARN of the database."
}

# s3 bucket variables
variable "scrub_scripts" {
  type        = list(string)
  description = "Optional; A list of scrub scripts. They will be run in the order specified in the list."
  default     = []
}

# cloudwatch event variables

# source variables
variable "source_schedule" {
  type        = string
  description = "Required; Cron schedule expression for when the downsync database dumps should be run. Expects format cron(0 7 ? * SAT *)"
}

# ecs variables
variable "image_tag" {
  type        = string
  description = "Versioned image tag used by the RDS Downsync Module. This image is maintained and supported by the USSBA. Image tag matches the version of the module."
}

# source ecs variables
variable "source_ecs_cluster" {
  type        = string
  description = "Required; Name of the ecs cluster that the db dump will be performed."
}
variable "source_subnets" {
  type        = list(string)
  description = "Required; List of private subnets that the db dump will be performed from."
}
variable "source_container_secrets" {
  type = list(object({
    name      = string
    valueFrom = string
  }))
  description = "Required; A secret name with a valueFrom path for db_user, db_password, and db_name."
  default     = []
}

# target ecs variables
variable "target_ecs_cluster" {
  type        = string
  description = "Required; Name of the ecs cluster that the db dump will be performed."
}
variable "target_subnets" {
  type        = list(string)
  description = "Required; List of private subnets that the db dump will be performed from."
}
variable "target_container_secrets" {
  type = list(object({
    name      = string
    valueFrom = string
  }))
  description = "Required; A secret name with a valueFrom path for db_user, db_password, and db_name."
  default     = []
}

# generic ecs variables consistent across environments
variable "cpu" {
  type        = number
  description = "Optional; vCPU that is assigned to the task definition. Defaults to 256."
  default     = 256
}
variable "memory" {
  type        = number
  description = "Optional; Memory that is assigned to the task definition. Defaults to 512."
  default     = 512
}

# s3 variables
variable "downsync_bucket_name" {
  type        = string
  description = "Optional; Name for the database downsync bucket."
}
variable "scrub_bucket_name" {
  type        = string
  description = "Optional; Name for the database scrub bucket."
}
