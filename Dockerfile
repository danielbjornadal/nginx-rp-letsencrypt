FROM ubuntu:bionic

MAINTAINER Daniel Bjørnådal <daniel@bjornadal.com>

# Install packages
RUN set -x \
	&& apt-get update \
    && apt-get -y install software-properties-common \
    && add-apt-repository universe \
    && add-apt-repository ppa:certbot/certbot \
    && apt-get update \
    && apt-get -y install cron gettext-base certbot python-certbot-nginx python3-acme python3-certbot-dns-cloudflare \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY conf.d /etc/nginx/conf.d
COPY nginx.conf /etc/nginx/
COPY entrypoint.sh .
COPY credentials credentials
COPY cron.d /etc/cron.d
RUN chmod 755 entrypoint.sh \
    && chmod -R 600 credentials \
    && useradd -ms /bin/bash nginx



# Let's Encrypt Configuration
ENV LETSENCRYPT_CHALLENGE=http
ENV LETSENCRYPT_EMAIL=
ENV LETSENCRYPT_DOMAINS=

# DNS Providers
ENV DNS_PROVIDER=
ENV CLOUDFLARE_EMAIL=
ENV CLOUDFLARE_KEY=

# Nginx Configuration
ENV NGINX_THREADS=2
ENV NGINX_SSL_PROTOCOLS="TLSv1.1 TLSv1.2"
ENV NGINX_SERVER_NAME=localhost
ENV NGINX_BACKEND_1="example.com max_fails=3 fail_timeout=30s"
ENV NGINX_BACKEND_2=""
ENV NGINX_BACKEND_3=""

ENTRYPOINT ["/entrypoint.sh"]