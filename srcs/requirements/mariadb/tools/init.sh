#!/bin/bash
set -e

DATA_DIR="/var/lib/mysql"
SOCKET="/run/mysqld/mysqld.sock"
INIT_FILE="$DATA_DIR/.initialized"

unset MYSQL_HOST
export MYSQL_UNIX_PORT=$SOCKET

echo "🟢 MariaDB init starting..."

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld
chown -R mysql:mysql $DATA_DIR

if [ ! -f "$INIT_FILE" ]; then
    echo "🟡 First initialization..."

    mysqld --user=mysql --skip-networking --socket=$SOCKET &
    pid="$!"

    echo "⏳ Waiting for MariaDB..."
    until mysqladmin --socket=$SOCKET ping; do
        sleep 1
    done

    mysql --socket=$SOCKET -u root <<EOF
#ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';


CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;


CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

    mysqladmin --socket=$SOCKET -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown
    wait "$pid"

    touch "$INIT_FILE"
    chown mysql:mysql "$INIT_FILE"

    echo "🟢 MariaDB initialized"
else
    echo "🔵 MariaDB already initialized"
fi

exec mysqld --user=mysql
