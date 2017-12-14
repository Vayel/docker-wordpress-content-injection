# docker-wordpress-content-injection

https://www.cvedetails.com/cve/CVE-2017-1001000/

## Run

```bash
docker-compose up
```

Check Wordpress version (must be either `4.7.0` or `4.7.1`):

```bash
docker exec -it <wordpress-container-id> cat wp-includes/version.php | grep "wp_version ="
```
