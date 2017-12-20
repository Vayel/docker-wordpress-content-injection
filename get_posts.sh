#!/bin/bash

. ./.env

if [[ -z "$1" ]]
then
    get_api $POSTS_ENDPOINT
else
    get_api "$POSTS_ENDPOINT?author=${AUTHOR_IDS[$1]}"
fi
