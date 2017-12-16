#!/bin/bash

. ./env.sh

title=mypost
content=mycontent
curl --data "title=$title&content=$content&status=publish" --user "$USER":"$PASSWORD" $POSTS_ENDPOINT
