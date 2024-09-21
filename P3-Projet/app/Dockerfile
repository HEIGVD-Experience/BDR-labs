FROM webdevops/php-nginx:8.2-alpine

ENV COMPOSER_ALLOW_SUPERUSER=1
ENV WEB_DOCUMENT_ROOT=/app/public

ENV COMPOSER_ALLOW_SUPERUSER=1

ENV APP_NAME=SportManagement
ENV APP_ENV=local
ENV APP_KEY=base64:6eX199v5HEgbqUrSAAGcGfsy/oZqwYu7jYYhqUTCwlg=
ENV APP_DEBUG=true
ENV APP_URL=http://sportmanagement.test
ENV DB_CONNECTION=pgsql
ENV DB_HOST=db
ENV DB_PORT=5432
ENV DB_DATABASE=bdr
ENV DB_USERNAME=postgres 
ENV DB_PASSWORD=trustno1

ENV PHP_DISMOD=bz2,calendar,exiif,ffi,intl,gettext,ldap,mysqli,imap,soap,sockets,sysvmsg,sysvsm,sysvshm,shmop,xsl,zip,gd,apcu,vips,yaml,imagick,mongodb,amqp

WORKDIR /app

COPY composer.json composer.lock artisan ./

RUN composer install --no-interaction --optimize-autoloader --no-dev

COPY . .

RUN php artisan optimize

# Ensure all of our files are owned by the same user and group.

RUN chown -R application:application .