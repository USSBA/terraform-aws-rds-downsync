# terraform-aws-rds-downsync

A terraform module abstracting a proven method for synchronizing an RDS database from once instance to another. In addition does support the ability to run custom SQL scripts that can be used for sanitization purposes during the restore operation.

**This module does not yet support cross account access.**

## Database Support

The module supports the following:
- Postgres (postgresql-client-10 | postgresql-client-11 | postgresql-client-12)
- MySQL (v5.6 and below)

## Container Environment

### Optional variables

- sql_client: A SQL client version. Must be one of the following: postgresql-client-10 | postgresql-client-11 | postgresql-client-12 | mysql-client. defaults to `postgres-client-12`

### Required variables

The following variables are required to be passed into the Terraform container.

- database: A single RDS Identifier that need to be downsynced.
- source_prefix: Prefix for the source and target aws resources.

### Source variables

- source_rds_identifier: The source identifier of your RDS instance that you will be downsyncing. It will also be included as part of the s3 object key when uploading/downloading the SQL dump file
- source_db_port: The port for the source SQL client. Example: 5432
- source_db_host: Source Host of the database. This can be a FQDN or the ARN of the database.
- source_bucket: Source bucket where the source database dumps are stored.
- source_schedule: Cron schedule expression for when the downsync database dumps should be run. Expects format ``cron(0 7 ? * SAT *)``.
- source_ecs_cluster: Name of the source ecs cluster that the db dump will be performed.
- source_subnets: List of private subnets that the db dump will be performed from.
- source_container_secrets: A secret name with a valueFrom path for db_user, db_password, and db_name for the source database.

### Target variables

- target_rds_identifier: The target identifier of your RDS instance that you will be restoring to.
- target_db_port: The port for the target SQL client. Example: 5432
- target_db_host: Target Host of the database. This can be a FQDN or the ARN of the database.
- target_ecs_cluster: Name of the target ecs cluster that the db restore will be performed.
- target_subnets: List of private subnets that the db restore will be performed from.
- target_container_secrets: A secret name with a valueFrom path for db_user, db_password, and db_namei for the target database.

### Example

```
module "activity_dump" {
  source = "../"

  image_tag = "v0.0.8"

  # database parameters
  sql_client = "postgresql-client-12"
  database   = "stg-activity-rds"

  # source resources
  source_prefix   = "abc"
  source_bucket   = "your-db-dump-bucket"
  source_schedule = "cron(0 7 ? * SAT *)"

  # source db
  source_db_port        = 5432
  source_rds_identifier = "your-prod-database"
  source_db_host        = "your-prod-database.domain.com" or "your-prod-database.aaaaaaaaaaaa.us-east-1.rds.amazonaws.com"

  # source network parameters
  source_ecs_cluster = "your-prod-cluster"
  source_subnets     = ["subnet-prod1", "subnet-prod2", "subnet-prod3"]

  # target network resources
  target_ecs_cluster = "your-stg-cluster"
  target_subnets     = ["subnet-stg1", "subnet-stg2", "subnet-stg3"]

  # target db
  target_db_port        = 5432
  target_rds_identifier = "your-stg-database"
  target_db_host        = "your-stg-database.domain.com" or "your-stg-database.aaaaaaaaaaaa.us-east-1.rds.amazonaws.com"

  # scrub bucket
  #scrub_bucket = "your-scrubs-bucket"
  #scrub_enabled = true
  #scrub_scripts = ["scrub01.sh", "scrub02.sh"]

  # source secrets
  source_container_secrets = [
    { name = "DBNAME", valueFrom = "arn:aws:ssm:${local.region}:${local.account_id}:parameter/path/to/param/db_name" },
    { name = "DBUSER", valueFrom = "arn:aws:ssm:${local.region}:${local.account_id}:parameter/path/to/param/username" },
    { name = "DBPASSWORD", valueFrom = "arn:aws:ssm:${local.region}:${local.account_id}:parameter/path/to/param/password" },
  ]

  # target secrets
  target_container_secrets = [
    { name = "DBNAME", valueFrom = "arn:aws:ssm:${local.region}:${local.account_id}:parameter/path/to/param/db_name" },
    { name = "DBUSER", valueFrom = "arn:aws:ssm:${local.region}:${local.account_id}:parameter/path/to/param/username" },
    { name = "DBPASSWORD", valueFrom = "arn:aws:ssm:${local.region}:${local.account_id}:parameter/path/to/param/password" },
  ]
}
```

## Build and Deployment Pipeline

This project is built with CircleCI and has the configuration [in this repository](./.circleci/config.yml).

### Feature Branch

When a new branch is pushed to GitHub, circleci will:

1) Tests the docker builds

### Tag based deployment

To trigger a build/deploy workflow for a specific environment, the following git tags can be used for their respective environments:

* Production -> `vX.X.X`

Production Example:
```sh
git tag v1.0.0 && git push origin v1.0.0
```
