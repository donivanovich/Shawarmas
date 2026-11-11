FROM php:8.3-apache

RUN apt-get update \
    && apt-get install -y --no-install-recommends libcurl4 libcurl4-openssl-dev \
    && docker-php-ext-install curl \
    && apt-get purge -y --auto-remove libcurl4-openssl-dev \
    && rm -rf /var/lib/apt/lists/*

ENV API_BASE_URL=http://api:3001/api/v1

COPY . /var/www/html/
