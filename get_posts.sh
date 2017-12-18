#!/bin/bash

. ./.env

curl --user "$USER":"$PASSWORD" $POSTS_ENDPOINT
