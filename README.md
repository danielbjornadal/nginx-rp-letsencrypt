# Nginx Reverse Proxy with Let's Encrypt

All-in-one Nginx reverse proxy that automatically renews your certificates.
 
The following DNS Providers/Validators is supported
* Selfsigned certificates
* HTTP Challenge
* CloudFlare DNS 
 

> [wikipedia.org/wiki/Nginx](https://en.wikipedia.org/wiki/Nginx)

![logo](https://raw.githubusercontent.com/docker-library/docs/01c12653951b2fe592c1f93a13b4e289ada0e3a1/nginx/logo.png)

# How to use this image

## The following environment variables are configurable
### Let's Encrypt Configuration
* `-e LETSENCRYPT_CHALLENGE=` (selfsigned, http or dns)
* `-e LETSENCRYPT_EMAIL=` (e-mail to register the certificate to. Will recieve notifications)
* `-e LETSENCRYPT_DOMAINS=` (Comma-separated list of domains to add to the cert)

### DNS Providers
* Supported providers: `cloudflare`
* `-e DNS_PROVIDER=` (if `LETSENCRYPT_CHALLENGE` = dns, specify the provider to use)
* `-e CLOUDFLARE_EMAIL=` (e-mail used with your cloudflare account)
* `-e CLOUDFLARE_KEY=` (API-key used with your cloudflare account)

### Nginx Configuration
* `-e NGINX_THREADS=` (Threads to start, default 2)
* `-e NGINX_SSL_PROTOCOLS=` (Supported protocols, default "TLSv1.1 TLSv1.2")
* `-e NGINX_SERVER_NAME=` (server domain name)
* `-e NGINX_BACKEND_1=` (Backend URL #1, default: "backend_url max_fails=3 fail_timeout=30s")
* `-e NGINX_BACKEND_2=` (Backend URL #2)
* `-e NGINX_BACKEND_3=` (Backend URL #3)

### Additional certbot arguments to append (ie. --staging)
* `-e CERTBOT_ARGS=` (Additional arguments to pass to certbot)

## Single backend with selfsigned certificate

```console
docker run -d --name nginx-rp \
    -p 80:80 -p 443:443 \
    -e NGINX_BACKEND_1="example.com max_fails=3 fail_timeout=30s" \
    bjornadalno/nginx-rp-letsencrypt
```

## Linked backend with selfsigned certificate (backend use port 8080)

```console
docker run -d --name nginx-rp \
    --link some_container:backend \
    -p 80:80 -p 443:443 \
    -e NGINX_BACKEND_1="backend:8080 max_fails=3 fail_timeout=30s" \
    bjornadalno/nginx-rp-letsencrypt
```

## Single backend with with HTTP validation

```console
docker run -d --name nginx-rp \
    -p 80:80 -p 443:443 \
    -e NGINX_SERVER_NAME="example.com" \
    -e NGINX_BACKEND_1="<bakend[:port]> max_fails=3 fail_timeout=30s" \
    -e LETSENCRYPT_CHALLENGE="http" \
    -e LETSENCRYPT_EMAIL="<your email>" \
    -e LETSENCRYPT_DOMAINS="example.com" \
    bjornadalno/nginx-rp-letsencrypt
```

## Single backend with Cloudflare as DNS Provider

```console
docker run -d --name nginx-rp \
    -p 80:80 -p 443:443 \
    -e NGINX_SERVER_NAME="example.com" \
    -e NGINX_BACKEND_1="<bakend[:port]> max_fails=3 fail_timeout=30s" \
    -e DNS_PROVIDER="cloudflare" \
    -e CLOUDFLARE_EMAIL="<your cloudflare email>" \
    -e CLOUDFLARE_KEY="<API key provided by cloudflare>" \
    -e LETSENCRYPT_CHALLENGE="dns" \
    -e LETSENCRYPT_EMAIL="<your email>" \
    -e LETSENCRYPT_DOMAINS="example.com[,*.example.com]" \
    bjornadalno/nginx-rp-letsencrypt
```
