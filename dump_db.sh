#!/bin/bash

if [[ -z "$1" ]]
then
    echo "Usage: ./dump_db.sh <container-id>"
    exit 1
fi

. ./.env

docker exec -it "$1" sh -c "mysqldump -u ${MYSQL_USER} -p${MYSQL_PASSWORD} ${MYSQL_DATABASE} > dump.sql"
docker cp "$1":/dump.sql ${MYSQL_DUMP_FNAME}
