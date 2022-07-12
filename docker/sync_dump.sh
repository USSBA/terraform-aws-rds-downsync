#!/bin/bash

if [[ ${SQL_CLIENT} == "mysql"* ]]; then
  echo "Running MySQL dump..."
  ${DUMP_OVERRIDE:-${DUMP}} > "db.tar"
else
  echo "Running Postgres dump..."
  ${DUMP_OVERRIDE:-${DUMP}} > "db.tar"
fi

echo "Copying ${RDS_IDENTIFIER} dump file to s3"
aws s3 cp "db.tar" "s3://${SOURCE_BUCKET}/${SOURCE_RDS_IDENTIFIER}/db.tar"
