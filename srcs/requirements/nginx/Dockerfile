FROM debian:bullseye

RUN apt-get update && apt-get install -y nginx curl netcat\
	openssl && apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

RUN mkdir -p /run/nginx \
	&& chown -R www-data:www-data /run/nginx	



COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY tools/init_nginx.sh /init_nginx.sh

RUN chmod +x /init_nginx.sh


ENTRYPOINT ["/init_nginx.sh"]
