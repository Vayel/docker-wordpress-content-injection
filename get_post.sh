#!/bin/bash

. ./.env

id1=10
id2=11

echo "With id in url body:"
url="$POSTS_ENDPOINT/$id1"
echo $url
echo ""
curl --user "$USER":"$PASSWORD" $url

echo -e "\n--------------------------------"
echo "With non-numeric id in url body (raises an error):"
url="$POSTS_ENDPOINT/${id1}ABC"
echo $url
echo ""
curl --user "$USER":"$PASSWORD" $url

echo -e "\n--------------------------------"
echo "With id in url query param (overrides id in url body):"
url="$POSTS_ENDPOINT/$id1?id=$id2"
echo $url
echo ""
curl --user "$USER":"$PASSWORD" $url

echo -e "\n--------------------------------"
echo "With non-numeric id in url query param (does not raise any error):"
url="$POSTS_ENDPOINT/$id1?id=${id2}ABC"
echo $url
echo ""
curl --user "$USER":"$PASSWORD" $url
