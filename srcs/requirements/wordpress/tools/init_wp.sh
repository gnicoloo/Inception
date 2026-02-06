#!/bin/bash
set -e

chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# Directory WordPress
cd /var/www/html

# Attendi MariaDB
until mysqladmin ping -h"${WORDPRESS_DB_HOST%%:*}" -u"${WORDPRESS_DB_USER}" -p"${WORDPRESS_DB_PASSWORD}" >/dev/null 2>&1; do
    echo "⏳ Waiting for MariaDB..."
    sleep 2
done
echo "✅ MariaDB is up!"
# Cancella wp-config.php se presente (solo per testing)
#rm -f wp-config.php


# WP-CLI: se non esiste, scaricalo
if [ ! -f wp-cli.phar ]; then
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
fi

echo "WP-CLI ready"

# Install WordPress only if not installed
if ! ./wp-cli.phar core is-installed --allow-root; then
    echo "🟡 WordPress not installed, installing..."

    if [ ! -f wp-settings.php ]; then
        ./wp-cli.phar core download --allow-root
        echo "WordPress files downloaded"
    fi

    if [ ! -f wp-config.php ]; then
        ./wp-cli.phar config create \
            --dbname="${WORDPRESS_DB_NAME}" \
            --dbuser="${WORDPRESS_DB_USER}" \
            --dbpass="${WORDPRESS_DB_PASSWORD}" \
            --dbhost="${WORDPRESS_DB_HOST}" \
            --allow-root
        echo "wp-config.php created"
    fi

    ./wp-cli.phar core install \
        --url="https://${DOMAIN_NAME}" \
        --title="inception" \
        --admin_user="${WORDPRESS_ADMIN_USER}" \
        --admin_password="${WORDPRESS_ADMIN_PASSWORD}" \
        --admin_email="${WORDPRESS_ADMIN_EMAIL}" \
        --allow-root

    echo "🟢 WordPress installed successfully"
# Crea utente WordPress secondario se non esiste
     if ! ./wp-cli.phar user get "${WORDPRESS_USER}" --allow-root >/dev/null 2>&1; then
        ./wp-cli.phar user create \
            "${WORDPRESS_USER}" "${WORDPRESS_USER_EMAIL}" \
             --user_pass="${WORDPRESS_USER_PASSWORD}" \
             --role=subscriber \
             --allow-root
         echo "User '${WORDPRESS_USER}' created successfully!"
     fi

else
    echo "🔵 WordPress already installed"
fi

# Assicurati dei permessi
chown -R www-data:www-data /var/www/html/wp-content

echo "Initialization script completed!"



# 🔥 necessario per php-fpm (pid file)
mkdir -p /run/php
chown -R www-data:www-data /run/php

#exec /usr/sbin/php-fpm8.2 -F

exec php-fpm8.2 -F
