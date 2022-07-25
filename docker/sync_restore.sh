#!/bin/bash

echo "Downloading database dump from s3"
aws s3 cp "s3://${SOURCE_BUCKET}/${SOURCE_RDS_IDENTIFIER}/db.tar" .

if [[ ${SQL_CLIENT} == "mysql"* ]]; then
  echo "Running MySQL dump..."
  ${RESTORE_OVERRIDE:-${RESTORE}} > "db.tar"
  ls -al
else
  echo "Running Postgres dump..."
  ${RESTORE_OVERRIDE:-${RESTORE}} < "db.tar"
  STATUS_CODE=$?
  if [[ ${STATUS_CODE} != 0 ]];
  then
    echo "There was an error with the Postgres restore..."
  else
    echo "Restore complete..."
  fi
fi

if [[ ! -z ${SCRUB_SCRIPTS} ]]; then
  for x in $SCRUB_SCRIPTS;
  do
    echo "Downloading ${x} from s3"
    aws s3 cp s3://${SCRUB_BUCKET}/${x} .
    echo "Substituting environment variables in ${x}"
    envsubst < ${x} > ${x}
    #aws s3 cp s3://${S3_BUCKET}/${x} .
    echo "Running script ${x} against ${TARGET_RDS_IDENTIFIER}"
    ${SQL} ${x}
  done
fi
