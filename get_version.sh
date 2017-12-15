#!/bin/bash

docker exec -it "$1" cat /usr/src/wordpress/wp-includes/version.php | grep "wp_version ="
