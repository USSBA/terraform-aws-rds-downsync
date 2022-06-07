#!/bin/bash

if [[ ${SQL_CLIENT} == "mysql"* ]]; then
  echo "Running MySQL dump..."
  ${DUMP_OVERRIDE:-${DUMP}} > "db_${TIMESTAMP}.sql"
else
  echo "Running Postgres dump..."
  ${DUMP_OVERRIDE:-${DUMP}} "db_${TIMESTAMP}.sql"
fi

echo "Copying ${RDS_IDENTIFIER} dump file to s3"
aws s3 cp "db_${TIMESTAMP}.sql" "s3://${S3_BUCKET}/${RDS_IDENTIFIER}/db_${TIMESTAMP}.sql"
