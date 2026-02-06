#!/bin/bash
set -e

echo "=============================="
echo "🔎 Inception Project Checks"
echo "=============================="

# 1️⃣ Docker Images
for img in nginx wordpress mariadb; do
    if docker images -q "srcs-$img" >/dev/null 2>&1; then
        echo "✅ Image 'srcs-$img' exists"
    else
        echo "❌ Image 'srcs-$img' missing"
    fi
done

# 2️⃣ Docker Containers
for svc in nginx wordpress mariadb; do
    CONTAINER=$(docker ps -q -f name="srcs-$svc-1")
    if [ -n "$CONTAINER" ]; then
        echo "✅ Container '$svc' running"
    else
        echo "❌ Container '$svc' NOT running"
    fi
done

# 3️⃣ Docker Network
NETWORK=$(docker network ls | grep srcs_backend)
if [ -n "$NETWORK" ]; then
    echo "✅ Docker network 'srcs_backend' exists"
else
    echo "❌ Docker network 'srcs_backend' missing"
fi

# 4️⃣ Volumes Persistence
for vol in srcs_wordpress_data srcs_mariadb_data; do
    if docker volume ls | grep $vol >/dev/null 2>&1; then
        echo "✅ Volume '$vol' exists"
    else
        echo "❌ Volume '$vol' missing"
    fi
done

# 5️⃣ WordPress installed
WP_CONTAINER=$(docker ps -q -f name="srcs-wordpress-1")
if [ -n "$WP_CONTAINER" ]; then
    if docker exec "$WP_CONTAINER" ./wp-cli.phar core is-installed --allow-root >/dev/null 2>&1; then
        echo "✅ WordPress is installed"
    else
        echo "❌ WordPress is NOT installed"
    fi
else
    echo "❌ WordPress container not found"
fi
