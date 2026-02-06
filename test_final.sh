#!/bin/bash
set -e

echo "=============================="
echo "🔎 Inception Project Final Checks"
echo "=============================="

# Lista immagini e container
IMAGES=("srcs-nginx" "srcs-wordpress" "srcs-mariadb")
CONTAINERS=("srcs-nginx-1" "srcs-wordpress-1" "srcs-mariadb-1")
VOLUMES=("srcs_wordpress_data" "srcs_mariadb_data")
NETWORK="srcs_backend"
WORDPRESS_DIR="/home/gnicolo/data/wordpress"

echo "1️⃣  Docker Images"
for img in "${IMAGES[@]}"; do
    if docker image inspect "$img" >/dev/null 2>&1; then
        echo "✅ Image '$img' exists"
    else
        echo "❌ Image '$img' missing"
    fi
done

echo "2️⃣  Docker Containers"
for ctr in "${CONTAINERS[@]}"; do
    if docker ps -a --format '{{.Names}}' | grep -qw "$ctr"; then
        STATUS=$(docker inspect -f '{{.State.Status}}' "$ctr")
        echo "✅ Container '$ctr' exists, status: $STATUS"
    else
        echo "❌ Container '$ctr' missing"
    fi
done

echo "3️⃣  Docker Network"
if docker network inspect "$NETWORK" >/dev/null 2>&1; then
    echo "✅ Network '$NETWORK' exists"
else
    echo "❌ Network '$NETWORK' missing"
fi

echo "4️⃣  Volumes Persistence"
for vol in "${VOLUMES[@]}"; do
    if docker volume inspect "$vol" >/dev/null 2>&1; then
        echo "✅ Volume '$vol' exists"
    else
        echo "❌ Volume '$vol' missing"
    fi
done

echo "5️⃣  WordPress Installation"
WP_CONTAINER="srcs-wordpress-1"
if docker exec "$WP_CONTAINER" ./wp-cli.phar core is-installed --allow-root >/dev/null 2>&1; then
    echo "✅ WordPress is installed"
else
    echo "❌ WordPress is NOT installed"
fi

echo "6️⃣  WordPress Permissions Check"
OWNER_UID=$(stat -c "%u" "$WORDPRESS_DIR")
OWNER_GID=$(stat -c "%g" "$WORDPRESS_DIR")
if [ "$OWNER_UID" -eq 33 ] && [ "$OWNER_GID" -eq 33 ]; then
    echo "✅ WordPress directory permissions are correct (www-data)"
else
    echo "❌ WordPress directory permissions incorrect: UID=$OWNER_UID, GID=$OWNER_GID"
fi

echo "7️⃣  SSL Certificate Check (NGINX)"
NGINX_CONTAINER="srcs-nginx-1"
if docker exec "$NGINX_CONTAINER" test -f /etc/nginx/ssl/inception.crt && \
   docker exec "$NGINX_CONTAINER" test -f /etc/nginx/ssl/inception.key; then
    echo "✅ SSL certificate and key exist"
else
    echo "❌ SSL certificate or key missing"
fi

echo "=============================="
echo "🎯 All checks completed!"
