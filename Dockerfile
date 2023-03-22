FROM php:8.1-cli-alpine

ENV TZ=Asia/Shanghai
ENV CHOKIDAR_USEPOLLING=true
ENV PHP_ENV=production
ENV PHP_POST_MAX_SIZE=100m
ENV PHP_UPLOAD_MAX_FILESIZE=100m

RUN addgroup -S www && adduser -S www -G www

RUN apk update && apk upgrade && apk add tzdata git npm supervisor

RUN ln -sf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN docker-php-source extract && docker-php-ext-install pcntl bcmath pdo_mysql opcache && docker-php-source delete

COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
RUN install-php-extensions zip xlswriter imagick
RUN install-php-extensions @composer
RUN install-php-extensions redis
RUN install-php-extensions swoole

COPY entrypoint.sh /usr/local/bin/entrypoint
COPY conf/supervisord.conf /etc/supervisord.conf
COPY conf/opcache.ini $PHP_INI_DIR/conf.d/docker-php-ext-opcache.ini

RUN rm -rf /usr/src/* && apk del && chmod +x /usr/local/bin/entrypoint
RUN git config --global --add safe.directory '*'

ENTRYPOINT ["entrypoint"]
