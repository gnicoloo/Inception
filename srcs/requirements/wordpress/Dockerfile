FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    lsb-release mailutils ca-certificates apt-transport-https \
    software-properties-common curl gnupg2 unzip mariadb-client

RUN curl -fsSL https://packages.sury.org/php/README.txt | bash
RUN echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" \
    > /etc/apt/sources.list.d/php.list
RUN curl -fsSL https://packages.sury.org/php/apt.gpg \
    | gpg --dearmor -o /etc/apt/trusted.gpg.d/php.gpg

RUN apt-get update && apt-get install -y \
    php8.2 php8.2-fpm php8.2-mysql php8.2-curl \
    php8.2-gd php8.2-xml php8.2-mbstring \
    mariadb-client curl unzip \
    && rm -rf /var/lib/apt/lists/*

# installa WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp


# directory necessaria a php-fpm (pid file)
RUN mkdir -p /run/php && chown -R www-data:www-data /run/php
# 🔥 elimina QUALSIASI pool di default
RUN rm -f /etc/php/8.2/fpm/pool.d/*

# 🔥 copia SOLO il tuo pool
COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

# 🔎 debug: mostra quale config viene caricata
RUN php-fpm8.2 -tt

WORKDIR /var/www/html

COPY tools/init_wp.sh /init_wp.sh
RUN chmod +x /init_wp.sh

EXPOSE 9000

# ENTRYPOINT mantiene init WP
ENTRYPOINT ["/init_wp.sh"]

# CMD esegue php-fpm in foreground
CMD ["php-fpm8.2", "-F"]
