FROM php:7.3-rc-fpm-alpine3.8
RUN apk update && apk add dcron tzdata && rm -rf /var/cache/apk/* \
&& ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
&& echo "Asia/Shanghai" > /etc/timezone
RUN mkdir -p /var/log/cron && mkdir -m 0644 -p /var/spool/cron/crontabs && touch /var/log/cron/cron.log && mkdir -m 0644 -p /etc/cron.d
RUN crontab -l | { cat; echo "0 * * * * php /var/www/html/one.php token:refresh"; } | crontab -
RUN crontab -l | { cat; echo "*/10 * * * * php /var/www/html/one.php cache:refresh >> /tmp/one.refresh.log"; } | crontab -

WORKDIR /var/www/html
COPY / /var/www/html/
RUN apk add --no-cache nginx \
    && mkdir /run/nginx \
    && chown -R www-data:www-data cache/ config/ \
    && mv default.conf /etc/nginx/conf.d \
    && mv php.ini /usr/local/etc/php

EXPOSE 80
# Persistent config file and cache
VOLUME [ "/var/www/html/config", "/var/www/html/cache" ]

CMD php-fpm & \
    nginx -g "daemon off;"