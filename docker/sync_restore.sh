#!/bin/bash

STARTTIME=$(date +"%Y-%m-%d")

echo "Running database restore"
aws s3 cp "s3://${S3_BUCKET}/${RDS_IDENTIFIER}/db_${STARTTIME}.sql" .
${RESTORE_OVERRIDE:-${RESTORE}} "db_${STARTTIME}.sql"

if [[ ! -z ${SCRUB_SCRIPTS} ]]; then
  for x in $SCRUB_SCRIPTS;
  do
    aws s3 cp s3://${S3_BUCKET}/${x} .
    echo "Running scrub script ${x}"
    ${SQL} ${x}
  done
fi
