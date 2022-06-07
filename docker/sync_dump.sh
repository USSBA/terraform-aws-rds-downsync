#!/bin/bash

STARTTIME=$(date +"%Y-%m-%d")

if [[ ${SQL_CLIENT} == "mysql"* ]]; then
  echo "Running MySQL dump..."
  ${DUMP_OVERRIDE:-${DUMP}} > "db_${STARTTIME}.sql"
  ls -al
else
  echo "Running Postgres dump..."
  ${DUMP_OVERRIDE:-${DUMP}} "db_${STARTTIME}.sql"
fi

echo "Copying ${RDS_IDENTIFIER} dump file to s3"
aws s3 cp "db_${STARTTIME}.sql" "s3://${S3_BUCKET}/${RDS_IDENTIFIER}/db_${STARTTIME}.sql"
