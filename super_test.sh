#!/bin/bash
set -e

# ==============================
# 🔎 Inception Project SUPER Checks
# ==============================

# Load environment variables
ENV_FILE="secrets/.env"
if [ -f "$ENV_FILE" ]; then
    export $(grep -v '^#' $ENV_FILE | xargs)
else
    echo "❌ .env file not found!"
    exit 1
fi

echo "=============================="
echo "🔎 Inception Project SUPER Checks"
echo "=============================="

# Helper: get container ID by service name
get_container() {
    docker ps -qf "name=$1"
}

# 1️⃣ Docker Images
echo "1️⃣  Docker Images"
for img in srcs-nginx srcs-wordpress srcs-mariadb; do
    if docker images -q "$img" >/dev/null; then
        echo "✅ Image '$img' exists"
    else
        echo "❌ Image '$img' missing"
    fi
done

# 2️⃣ Docker Containers
echo "2️⃣  Docker Containers"
for svc in srcs-nginx-1 srcs-wordpress-1 srcs-mariadb-1; do
    CID=$(get_container $svc)
    if [ -n "$CID" ]; then
        STATUS=$(docker inspect -f '{{.State.Status}}' $CID)
        echo "✅ Container '$svc' exists, status: $STATUS"
    else
        echo "❌ Container '$svc' missing"
    fi
done

# 3️⃣ Docker Network
echo "3️⃣  Docker Network"
if docker network inspect srcs_backend >/dev/null 2>&1; then
    echo "✅ Network 'srcs_backend' exists"
else
    echo "❌ Network 'srcs_backend' missing"
fi

# 4️⃣ Volumes Persistence
echo "4️⃣  Volumes Persistence"
for vol in srcs_wordpress_data srcs_mariadb_data; do
    if docker volume inspect $vol >/dev/null 2>&1; then
        echo "✅ Volume '$vol' exists"
    else
        echo "❌ Volume '$vol' missing"
    fi
done

# 5️⃣ WordPress Installation
echo "5️⃣  WordPress Installation"
WP_CONTAINER=$(get_container srcs-wordpress-1)
if docker exec "$WP_CONTAINER" ./wp-cli.phar core is-installed --allow-root >/dev/null 2>&1; then
    echo "✅ WordPress is installed"
else
    echo "❌ WordPress is NOT installed"
fi

# 6️⃣ WordPress Users Check
echo "6️⃣  WordPress Users Check"
USERS=("$WORDPRESS_ADMIN_USER" "$WORDPRESS_USER")
for u in "${USERS[@]}"; do
    if docker exec "$WP_CONTAINER" ./wp-cli.phar user get "$u" --allow-root >/dev/null 2>&1; then
        echo "✅ WordPress user '$u' exists"
    else
        echo "❌ WordPress user '$u' missing"
    fi
done

# 7️⃣ WordPress PHP-FPM
echo "7️⃣  WordPress PHP-FPM"
if docker exec "$WP_CONTAINER" pgrep php-fpm >/dev/null 2>&1; then
    echo "✅ php-fpm is running in WordPress container"
else
    echo "❌ php-fpm is NOT running"
fi

# 8️⃣ WordPress Directory Permissions
echo "8️⃣  WordPress Directory Permissions"
WP_DIR="/var/www/html"
PERM_OK=$(docker exec "$WP_CONTAINER" stat -c '%U:%G %a' $WP_DIR)
if [[ "$PERM_OK" == "www-data:www-data 755" || "$PERM_OK" == "33:33 755" ]]; then
    echo "✅ WordPress directory permissions are correct (www-data)"
else
    echo "❌ WordPress directory permissions incorrect: $PERM_OK"
fi

# 9️⃣ SSL Certificate Check (NGINX)
echo "9️⃣  SSL Certificate Check (NGINX)"
NGINX_CONTAINER=$(get_container srcs-nginx-1)
if docker exec "$NGINX_CONTAINER" test -f /etc/nginx/ssl/inception.crt && docker exec "$NGINX_CONTAINER" test -f /etc/nginx/ssl/inception.key; then
    echo "✅ SSL certificate and key exist"
else
    echo "❌ SSL certificate or key missing"
fi

# 🔟 Nginx Listening on 443
echo "🔟  Nginx Listening on 443"
if docker exec "$NGINX_CONTAINER" ss -tln | grep -q ':443'; then
    echo "✅ Nginx is listening on port 443"
else
    echo "❌ Nginx is NOT listening on port 443"
fi

# 1️⃣1️⃣ Container Connectivity Checks
echo "1️⃣1️⃣  Container Connectivity Checks"
# Nginx → WordPress (php-fpm)
if docker exec "$NGINX_CONTAINER" bash -c "</dev/tcp/wordpress/9000" >/dev/null 2>&1; then
    echo "✅ Nginx can reach WordPress container on php-fpm port"
else
    echo "❌ Nginx cannot reach WordPress container on php-fpm port"
fi

# WordPress → MariaDB
if docker exec "$WP_CONTAINER" ./wp-cli.phar db check --allow-root >/dev/null 2>&1; then
    echo "✅ WordPress can reach MariaDB container"
else
    echo "❌ WordPress cannot reach MariaDB container"
fi

# Optional: HTTPS from host
echo "1️⃣2️⃣  HTTPS Access Check"
if curl -sk https://$DOMAIN_NAME >/dev/null 2>&1; then
    echo "✅ WordPress reachable via HTTPS"
else
    echo "❌ WordPress NOT reachable via HTTPS"
fi

echo "=============================="
echo "🎯 SUPER Checks completed!"
