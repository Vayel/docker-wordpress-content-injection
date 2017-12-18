# docker-wordpress-content-injection

https://www.cvedetails.com/cve/CVE-2017-1001000/

## Install

```bash
docker-compose up
```

* Open `127.0.0.1:8080` and create a website.
* Check Wordpress version (should be 4.7 or 4.7.1): W (top left) > About Wordpress
* Enable the API: on the page [http://127.0.0.1:8080/wp-admin/options-permalink.php](http://127.0.0.1:8080/wp-admin/options-permalink.php), select `Post name` and save changes.
* Make sure the API is accessible: [http://127.0.0.1:8080/wp-json/](http://127.0.0.1:8080/wp-json/)
* Activate the plugin `JSON Basic Authentication` on [this page](http://127.0.0.1:8080/wp-admin/plugins.php)
* Play with the API using the scripts `get_posts.sh` and `create_post.sh`

# TODO

* Make the installation automatic (provide a database)
* Exploit the vulnerability
