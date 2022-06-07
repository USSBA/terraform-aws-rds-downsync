# terraform-aws-rds-downsync

A terraform module abstracting a proven method for synchronizing an RDS database from once instance to another. In addition does support the ability to run custom SQL scripts that can be used for sanitization purposes during the restore operation.

**This module does not yet support cross account access.**

## Database Support

The module supports the following:
- Postgres (postgresql-client-10 | postgresql-client-11 | postgresql-client-12)
- MySQL (v5.6 and below)

## Container Environment

### Required variables

The following variables are required to be passed into the Terraform container.

- RDS_IDENTIFIER: The identifier of your RDS instance.
It will also be included as part of the s3 object key when uploading/downloading the SQL dump file

```sh
s3://bucket-name/{rds-identifer}/db_{timestamp}.sql
```

- S3_BUCKET: The name of the s3 bucket where the database dumps and or scrub scripts will be stored

### Optional variables 

- DUMP_DIR: The directory within the container where dump and restore operations will be executed and files will be written and/or read. Potentially a good place to mount an EFS volume for working with larger databases.

- SQL_CLIENT: The SQL client matching that of your RDS instance. This must be one of the following, else it defaults to `postgres-client-12`.
  - postgres-client-10
  - postgres-client-11
  - postgres-client-12
  - mysql-client

### Database variables

Postgres client requires variables for connectivity.

- DBUSER
- DBPASSWORD
- DBNAME
- DBHOST
- DBPORT