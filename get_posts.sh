#!/bin/bash

. ./env.sh

curl -i -H "Accept: application/json" -H "Content-Type: application/json" -X GET --user "$USER":"$PASSWORD" $POSTS_ENDPOINT
