#!/bin/bash

. ./.env

if [[ -z "$2" ]]
then
    echo "Usage: ./create_post.sh <one-word-title> <one-word-content>"
    exit 1
fi

post_api $POSTS_ENDPOINT "title=$1&content=$2&status=publish"
