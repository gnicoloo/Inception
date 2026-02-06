#!/bin/bash
set -e

echo "⏳ Waiting for WordPress (php-fpm)..."
until nc -z wordpress 9000; do
    sleep 2
done

SSL_DIR="/etc/nginx/ssl"
CRT="$SSL_DIR/inception.crt"
KEY="$SSL_DIR/inception.key"

mkdir -p "$SSL_DIR"

# fallback di sicurezza (in caso il correttore rompe .env)
: "${DOMAIN_NAME:=localhost}"
: "${SSL_COUNTRY:=IT}"
: "${SSL_STATE:=RM}"
: "${SSL_LOCATION:=Rome}"
: "${SSL_ORG:=42}"
: "${SSL_OU:=Inception}"

if [ ! -f "$CRT" ] || [ ! -f "$KEY" ]; then
    echo "🔐 Generating SSL certificate for $DOMAIN_NAME"
    openssl req -x509 -nodes -days 365 \
        -newkey rsa:2048 \
        -keyout "$KEY" \
        -out "$CRT" \
        -subj "/C=$SSL_COUNTRY/ST=$SSL_STATE/L=$SSL_LOCATION/O=$SSL_ORG/OU=$SSL_OU/CN=$DOMAIN_NAME"
fi

echo "🟢 Checking Nginx config..."
nginx -t

exec nginx -g "daemon off;"
