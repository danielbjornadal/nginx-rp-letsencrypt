#!/bin/bash
set -e

# Replace all variables
for v in $(compgen -e); do
    sed -i "s|\\\$ENV{\"${v}\"}|${!v}|g" /etc/nginx/conf.d/*
    sed -i "s|\\\$ENV{\"${v}\"}|${!v}|g" /etc/nginx/nginx.conf
done

# Remove lines containing only: server;
sed -i '/^\s*server\s*;$/d' /etc/nginx/conf.d/default.conf

# Populate the credentials file from environment variables
envsubst < /credentials/${DNS_PROVIDER,,} > /credentials/${DNS_PROVIDER,,}

# Create selfsigned certificate
if [[ ! -f /etc/letsencrypt/live/nginx/privkey.pem ]] && [[ ! -f /etc/letsencrypt/live/nginx/fullchain.pem ]];
then
    mkdir -p /etc/letsencrypt/live/nginx
    openssl req -x509 -nodes -subj "/CN=${NGINX_SERVER_NAME,,}" -newkey rsa:2048 -keyout /etc/letsencrypt/live/nginx/privkey.pem -out /etc/letsencrypt/live/nginx/fullchain.pem -days 3650
fi

nginx

sleep 5

# HTTP Challenge Validation
if [[ ${LETSENCRYPT_CHALLENGE,,} = http ]] || [[ -z ${LETSENCRYPT_CHALLENGE} =  ]];
then
    certbot --nginx -n --agree-tos -m ${LETSENCRYPT_EMAIL} --preferred-challenges http --cert-name nginx -d ${NGINX_SERVER_NAME,,} --staging
fi


# DNS Challenge Validation
if [[ ${LETSENCRYPT_CHALLENGE,,} = dns ]];
then

    if [[ ! -f /credentials/${DNS_PROVIDER,,} ]]
    then
        echo "DNS_PROVIDER not supported"
        exit 1
    fi
    # Run certbot
    if [[ ${DNS_PROVIDER,,} = cloudflare ]];
    then
        dns_provider_string="--dns-cloudflare --dns-cloudflare-credentials /credentials/${DNS_PROVIDER,,}"
        # certbot certonly -n --agree-tos --test-cert -m ${LETSENCRYPT_EMAIL} $dns_provider_string --cert-name nginx -d "${LETSENCRYPT_DOMAINS}"
        certbot certonly -n --agree-tos -m ${LETSENCRYPT_EMAIL} $dns_provider_string --cert-name nginx -d "${LETSENCRYPT_DOMAINS}"
        crontab /etc/cron.d/*
        /etc/init.d/cron start
    fi
fi


# Start Nginx
# exec 