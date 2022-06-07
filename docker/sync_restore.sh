#!/bin/bash

echo "Downloading database dump from s3"
aws s3 cp "s3://${S3_BUCKET}/${RDS_IDENTIFIER}/db_${TIMESTAMP}.sql" .

if [[ ${SQL_CLIENT} == "mysql"* ]]; then
  echo "Running MySQL dump..."
  ${RESTORE_OVERRIDE:-${RESTORE}} > "db_${TIMESTAMP}.sql"
  ls -al
else
  echo "Running Postgres dump..."
  ${RESTORE_OVERRIDE:-${RESTORE}} "db_${TIMESTAMP}.sql"
fi

if [[ ! -z ${SCRUB_SCRIPTS} ]]; then
  for x in $SCRUB_SCRIPTS;
  do
    echo "Downloading ${x} from s3"
    aws s3 cp s3://${S3_BUCKET}/${x} .
    echo "Running script ${x} against ${RDS_IDENTIFIER}"
    ${SQL} ${x}
  done
fi
