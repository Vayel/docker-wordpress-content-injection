#!/bin/bash

. ./.env

if [[ -z "$1" ]]
then
    echo "Usage: ./get_post.sh <id> [user]"
    exit 1
fi

get_api "$POSTS_ENDPOINT/$1" $2
