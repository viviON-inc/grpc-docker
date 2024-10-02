ARG PHP_BASEIMAGE_TAG
FROM php:${PHP_BASEIMAGE_TAG}

WORKDIR /work

RUN apt update -y && \
  apt install -y \
  git \
  build-essential \
  autoconf \
  zlib1g-dev

COPY --from=composer /usr/bin/composer /usr/bin/composer

COPY --from=ghcr.io/vivion-inc/grpc-docker:php7.4-pecl -grpc1.66.0-bullseye /usr/local/lib/php/extensions/grpc.so /tmp/grpc.so

RUN mv /tmp/grpc.so $(php-config --extension-dir)/grpc.so && \
  pecl install protobuf && \
  docker-php-ext-enable grpc protobuf

RUN git clone --recurse-submodules -b v1.66.0 --depth 1 --shallow-submodules https://github.com/grpc/grpc
RUN cd grpc/examples/php && \
  composer install
