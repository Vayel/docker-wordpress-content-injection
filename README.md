# docker-wordpress-content-injection

https://www.cvedetails.com/cve/CVE-2017-1001000/

## Run

```bash
docker-compose up
```

Check Wordpress version (must be either `4.7.0` or `4.7.1`):

```bash
docker ps | grep wordpress
./get_version.sh <wordpress-container-id>
```
