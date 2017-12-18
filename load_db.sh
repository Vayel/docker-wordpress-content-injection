#!/bin/bash

if [[ -z "$1" ]]
then
    echo "Usage: ./load_db.sh <container-id>"
    exit 1
fi

. ./.env

docker cp ${MYSQL_DUMP_FNAME} "$1":/dump.sql
docker exec -it "$1" sh -c "mysql -u ${MYSQL_USER} -p${MYSQL_PASSWORD} ${MYSQL_DATABASE} < dump.sql"
