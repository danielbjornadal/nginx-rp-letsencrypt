# Nginx Reverse Proxy with Let's Encrypt

All-in-one Nginx reverse proxy that automatically renews your certificates.
 
The following DNS Providers/Validators is supported
* Selfsigned certificates
* CloudFlare DNS 

> [wikipedia.org/wiki/Nginx](https://en.wikipedia.org/wiki/Nginx)

![logo](https://raw.githubusercontent.com/docker-library/docs/01c12653951b2fe592c1f93a13b4e289ada0e3a1/nginx/logo.png)

# How to use this image

## Single backend with selfsigned certificate

```console
docker run -d --name nginx-rp -p 80:80 -p 443:443 -e NGINX_BACKEND_1="example.com max_fails=3 fail_timeout=30s" danielbjornadal/nginx-rp-letsencrypt
```

## Single backend with Cloudflare as DNS Provider

```console
docker run -d --name nginx-rp \
    -p 80:80 -p 443:443 \
    -e NGINX_SERVER_NAME="yourdomain.com" \
    -e NGINX_BACKEND_1="example.com max_fails=3 fail_timeout=30s" \
    -e DNS_PROVIDER="cloudflare" \
    -e CLOUDFLARE_EMAIL="<your cloudflare email>" \
    -e CLOUDFLARE_KEY="<API key provided by cloudflare>" \
    -e LETSENCRYPT_EMAIL="<your email>" \
    -e LETSENCRYPT_DOMAINS="<example.com,*.example.com>" \
    danielbjornadal/nginx-rp-letsencrypt
```


ENV =
ENV =