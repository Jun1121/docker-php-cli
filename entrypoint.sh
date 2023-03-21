#!/bin/sh
set -e

env >>/etc/environment

/bin/cp -f "$PHP_INI_DIR/php.ini-$PHP_ENV" "$PHP_INI_DIR/php.ini"

sed -i "s/expose_php = On/expose_php = Off/g" "$PHP_INI_DIR"/php.ini
sed -i "s/post_max_size = 8M/post_max_size = $PHP_POST_MAX_SIZE/g" "$PHP_INI_DIR"/php.ini
sed -i "s/upload_max_filesize = 2M/post_max_size = $PHP_UPLOAD_MAX_FILESIZE/g" "$PHP_INI_DIR"/php.ini

if [ "$PHP_ENV" = "development" ]; then
  sed -i "s/opcache.enable = 1/opcache.enable = 0/g" "$PHP_INI_DIR"/conf.d/docker-php-ext-opcache.ini
  sed -i "s/opcache.enable_cli = 1/opcache.enable_cli = 0/g" "$PHP_INI_DIR"/conf.d/docker-php-ext-opcache.ini
fi

/usr/sbin/crond -b -L /var/log/cron.log

if [ "$#" != 0 ]; then
  for arg in "$@"; do
    $arg
  done
fi

/usr/bin/supervisord -c /etc/supervisord.conf
