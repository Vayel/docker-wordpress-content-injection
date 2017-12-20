#!/bin/bash

. ./.env

if [[ -z "$2" ]]
then
    echo "Usage: ./get_post_query_param.sh <id_url_body> <id_query_param>"
    exit 1
fi

get_api "$POSTS_ENDPOINT/$1?id=$2"
