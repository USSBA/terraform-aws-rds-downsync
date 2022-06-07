# terraform-aws-rds-downsync

The RDS downsync module is responsible for taking a database dump from a environment and restoring it to another (prod > stg). The environments currently must be in the same AWS account.
This module does not yet support cross account access.

## Database Support

The module supports the following:
- Postgres (postgresql-client-10 | postgresql-client-11 | postgresql-client-12)
- MySQL (v5.6 and below)

## Required Variables

The following variables are required to be passed into the Terraform container.

- DUMP_DIR: The local directory where the database dump will be stored before being sent to s3. Defaults to `/tmp/files`.

- SQL_CLIENT: This must be one of the following, else it defaults to `postgres-client-12`.
  - postgres-client-10
  - postgres-client-11
  - postgres-client-12
  - mysql-client

- RDS_IDENTIFIER: The identifier of your RDS database. This will be used to dump or restore the appropriate database. It will also be used as a subfolder in s3, where the database file is stored.

- S3_BUCKET: The name of the s3 bucket where the database dumps and or scrub scripts will be stored

### Postgres variables used by the `postgres-client`

Postgres client requires variables for connectivity. If using the `postgres-client` pass these variables into the module.

- PGUSER
- PGPASSWORD
- PGDATABASE
- PGHOST
- PGPORT

### MySQL variables used by the `mysql-client`

MySQL client requires variables for connectivity. If using the `mysql-client` pass these variables into the module.

- MYSQL_USER
- MYSQL_HOST
- MYSQL_PWD
- MYSQL_DATABASE
