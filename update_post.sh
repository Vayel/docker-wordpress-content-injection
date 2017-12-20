#!/bin/bash

. ./.env

if [[ -z "$2" ]]
then
    echo "Usage: ./update_post.sh <post-id> <one-word-content>"
    exit 1
fi

post_api "$POSTS_ENDPOINT/$1" "content=$2"
