#!/bin/sh

# lets use postgres 12 by default
export SQL_CLIENT=${SQL_CLIENT:-postgresql-client-12}

echo "Updaing Packages"
apt-get update

case $SQL_CLIENT in
  postgresql*)
    apt-get install -y $SQL_CLIENT
    export DUMP="pg_dump --verbose --format c -f"
    export RESTORE="pg_restore --verbose"
    export SQL="psql -f"
  ;;
  mysql*)
    apt-get install -y $SQL_CLIENT
    export DUMP="mysqldump"
    export RESTORE="mysql"
    export SQL="mysql"
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
