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
