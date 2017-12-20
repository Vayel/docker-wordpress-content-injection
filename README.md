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

# Exploit

The requests are handled in `wordpress/wp-includes/rest-api/endpoints/class-wp-rest-posts-controller.php`
[line 80](https://github.com/Vayel/docker-wordpress-content-injection/blob/master/wordpress/wp-includes/rest-api/endpoints/class-wp-rest-posts-controller.php#L80).

The route needs a post id in the url:

```bash
./get_post.sh
```

If the id is not numeric, the API returns an error:

```bash
./get_post_non_numeric.sh
```

If a query param `id` is specified, its value overrides the one in the url body:

```bash
./get_post_query_param.sh
# The obtained id is 11 and not 10
```

But if the query param id is not numeric, no errors are raised:

```bash
./get_post_query_param_non_numeric.sh
```
