#!/bin/bash
set -e

if [[ ! -f /credentials/${DNS_PROVIDER,,} ]]
then
    echo "DNS_PROVIDER not supported"
    exit 1
fi

# Replace all variables
for v in $(compgen -e); do
    sed -i "s|\\\$ENV{\"${v}\"}|${!v}|g" /etc/nginx/conf.d/*
    sed -i "s|\\\$ENV{\"${v}\"}|${!v}|g" /etc/nginx/nginx.conf
done

# Remove lines containing only ;
sed -i '/^\s*server\s*;$/d' /etc/nginx/conf.d/default.conf

# Populate the credentials file from environment variables
envsubst < /credentials/${DNS_PROVIDER,,} > /credentials/${DNS_PROVIDER,,}

if [[ ${DNS_PROVIDER,,} = selfsigned ]] && [[ ! -f /etc/letsencrypt/live/nginx/privkey.pem ]] && [[ ! -f /etc/letsencrypt/live/nginx/fullchain.pem ]];
then
    mkdir -p /etc/letsencrypt/live/nginx
    openssl req -x509 -nodes -subj "/CN=${NGINX_SERVER_NAME,,}" -newkey rsa:2048 -keyout /etc/letsencrypt/live/nginx/privkey.pem -out /etc/letsencrypt/live/nginx/fullchain.pem -days 3650
fi

# Run certbot
if [[ ${DNS_PROVIDER,,} = cloudflare ]];
then
    dns_provider_string="--dns-cloudflare --dns-cloudflare-credentials /credentials/${DNS_PROVIDER,,}"
    certbot certonly -n --agree-tos --test-cert -m ${LETSENCRYPT_EMAIL} $dns_provider_string --cert-name nginx -d "${LETSENCRYPT_DOMAINS}"
    crontab /etc/cron.d/*
    /etc/init.d/cron start
fi

# Start Nginx
exec "$@"