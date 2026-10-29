FROM node:22-alpine AS assets

WORKDIR /app

COPY package.json vite.config.js ./
RUN npm install --no-audit --no-fund

COPY resources ./resources
COPY public ./public
RUN npm run build

FROM php:8.3-apache

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libcurl4-openssl-dev \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libonig-dev \
        libpng-dev \
        libpq-dev \
        libxml2-dev \
        libzip-dev \
        unzip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j"$(nproc)" \
        bcmath \
        curl \
        dom \
        gd \
        mbstring \
        opcache \
        pdo_pgsql \
        xml \
        zip \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer

WORKDIR /var/www/html

COPY . .
COPY --from=assets /app/public/build ./public/build
COPY docker/apache-vhost.conf /etc/apache2/sites-available/000-default.conf
COPY docker/entrypoint.sh /usr/local/bin/agriconnect-entrypoint

RUN printf 'Listen 10000\n' > /etc/apache2/ports.conf \
    && a2enmod rewrite headers \
    && chmod +x /usr/local/bin/agriconnect-entrypoint \
    && composer install --no-dev --no-interaction --prefer-dist --optimize-autoloader \
    && mkdir -p storage/app/private storage/app/public storage/framework/cache/data storage/framework/sessions storage/framework/views storage/logs bootstrap/cache \
    && chown -R www-data:www-data storage bootstrap/cache

ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
ENV PORT=10000

EXPOSE 10000

CMD ["agriconnect-entrypoint"]
