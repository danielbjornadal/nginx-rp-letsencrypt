#!/bin/bash
set -e

certbot_args=

# Replace all variables
for v in $(compgen -e); do
    sed -i "s|\\\$ENV{\"${v}\"}|${!v}|g" /etc/nginx/conf.d/*
    sed -i "s|\\\$ENV{\"${v}\"}|${!v}|g" /etc/nginx/nginx.conf
done

# Remove lines containing only: server;
sed -i '/^\s*server\s*;$/d' /etc/nginx/conf.d/default.conf

# Selfsigned
if [[ ${LETSENCRYPT_CHALLENGE,,} = selfsigned ]] || [[ -z ${LETSENCRYPT_CHALLENGE} ]];
then
    mkdir -p /etc/letsencrypt/live/nginx
    openssl req -x509 -nodes -subj "/CN=${NGINX_SERVER_NAME,,}" -newkey rsa:2048 -keyout /etc/letsencrypt/live/nginx/privkey.pem -out /etc/letsencrypt/live/nginx/fullchain.pem -days 3650
    echo "Using the following selfsigned certificate"
    cat /etc/letsencrypt/live/nginx/fullchain.pem
fi

if [[ -z ${STAGING} ]];
then
    certbot_args=--staging
fi

# HTTP Challenge Validation
if [[ ${LETSENCRYPT_CHALLENGE,,} = http ]] && [[ ! -f /etc/letsencrypt/live/nginx/privkey.pem ]] && [[ ! -f /etc/letsencrypt/live/nginx/fullchain.pem ]];
then
    certbot --nginx -n --agree-tos -m ${LETSENCRYPT_EMAIL} --preferred-challenges http --cert-name nginx -d ${NGINX_SERVER_NAME,,} ${certbot_args}
fi


# DNS Challenge Validation
if [[ ${LETSENCRYPT_CHALLENGE,,} = dns ]] && [[ ! -f /etc/letsencrypt/live/nginx/privkey.pem ]] && [[ ! -f /etc/letsencrypt/live/nginx/fullchain.pem ]];
then

    if [[ ! -f /credentials/${DNS_PROVIDER,,} ]]
    then
        echo "DNS_PROVIDER not supported"
        exit 1
    fi

    # Populate the credentials file from environment variables
    envsubst < /credentials/${DNS_PROVIDER,,} > /credentials/${DNS_PROVIDER,,}

    # Run certbot
    if [[ ${DNS_PROVIDER,,} = cloudflare ]];
    then
        dns_provider_string="--dns-cloudflare --dns-cloudflare-credentials /credentials/${DNS_PROVIDER,,}"
        certbot certonly -n --agree-tos -m ${LETSENCRYPT_EMAIL} $dns_provider_string --cert-name nginx -d "${LETSENCRYPT_DOMAINS}"
    fi
fi

crontab /etc/cron.d/*
/etc/init.d/cron start

# Start Nginx
exec "$@"