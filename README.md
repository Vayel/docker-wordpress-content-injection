# docker-wordpress-content-injection

https://www.cvedetails.com/cve/CVE-2017-1001000/

## Install

```bash
docker-compose up
```

* Check Wordpress version (must be either `4.7.0` or `4.7.1`):

```bash
docker ps | grep wordpress
./get_version.sh <wordpress-container-id>
```

* Open `127.0.0.1:8080` and create a website.
* Enable the API: on the page [http://127.0.0.1:8080/wp-admin/options-permalink.php](http://127.0.0.1:8080/wp-admin/options-permalink.php), select `Post name` and save changes.
* Make sure the API is accessible: [http://127.0.0.1:8080/wp-json/](http://127.0.0.1:8080/wp-json/)
* **(TODO: to be integrated to the Dockerfile)** Install and activate the plugin [`JSON Basic Authentication`](https://github.com/WP-API/Basic-Auth):
    * Télécharger [ce dépôt](https://github.com/WP-API/Basic-Auth) au format zip
    * Wordpress > Admin > Plugins > Add new > Upload Plugin
* Play with the API using the scripts `get_posts.sh` and `create_post.sh`

# TODO

* Make the installation automatic
* Exploit the vulnerability
