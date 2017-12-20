#!/bin/bash

. ./.env

get_api "$POSTS_ENDPOINT/$POST_ID1?id=${POST_ID2}ABC"
