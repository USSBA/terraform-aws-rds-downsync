#!/bin/bash

STARTTIME=$(date +"%Y-%m-%d")
echo "Running database dump..."
${DUMP_OVERRIDE:-${DUMP}} "db_${STARTTIME}.sql"
aws s3 cp "db_${STARTTIME}.sql" "s3://${S3_BUCKET}/${RDS_IDENTIFIER}/db_${STARTTIME}.sql"
