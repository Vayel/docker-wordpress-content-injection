#!/bin/bash

. ./.env

get_post "$POSTS_ENDPOINT/$POST_ID1?id=$POST_ID2"
