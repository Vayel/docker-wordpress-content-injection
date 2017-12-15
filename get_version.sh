#!/bin/bash

docker exec -it "$1" cat wp-includes/version.php | grep "wp_version ="
