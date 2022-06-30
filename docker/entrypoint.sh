#!/bin/sh

export TIMESTAMP=$(date +"%Y-%m-%d")

echo "Updaing Packages"
apt-get update

case $SQL_CLIENT in
  postgresql*)
    apt-get install -y $SQL_CLIENT
    export DUMP="pg_dump --verbose -Ft ${DBNAME}"
    export RESTORE="pg_restore --verbose -e --clean -Ft -d ${DBNAME}"
    #export DUMP="pg_dump --verbose --format c -f"
    #export RESTORE="pg_restore --verbose -f"
    export SQL="psql -f"
    export PGUSER=${DBUSER}
    export PGPASSWORD=${DBPASSWORD}
    export PGDATABASE=${DBNAME}
    export PGHOST=${DBHOST}
    export PGPORT=${DBPORT}
  ;;
  mysql*)
    apt-get install -y $SQL_CLIENT
    export DUMP="mysqldump"
    export RESTORE="mysql"
    export SQL="mysql"
    export MYSQL_USER=${DBUSER}
    export MYSQL_PWD=${DBPASSWORD}
    export MYSQL_DATABASE=${DBNAME}
    export MYSQL_HOST=${DBHOST}
    export MYSQL_TCP_PORT=${DBPORT}
  ;;
  *)
    echo "The SQL_CLIENT is not supported"
    echo "Supported Clients are [postgresql-client-10 | postgresql-client-11 | postgresql-client-12 | mysql-client]"
    exit 1
  ;;
esac

mkdir -p ${DUMP_DIR}
cd ${DUMP_DIR}

exec "$@"
