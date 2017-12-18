# docker-wordpress-content-injection

https://www.cvedetails.com/cve/CVE-2017-1001000/

## Install

```bash
docker-compose up
# In another terminal
./load_db.sh
```

* Open [http://127.0.0.1:8080/wp-admin/index.php](http://127.0.0.1:8080/wp-admin/index.php)
* Check Wordpress version (should be 4.7 or 4.7.1): W (top left) > About Wordpress
* Play with the API using the scripts `get_posts.sh` and `create_post.sh`

# TODO

* Exploit the vulnerability
