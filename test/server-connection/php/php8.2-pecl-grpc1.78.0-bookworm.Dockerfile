ARG PHP_BASEIMAGE_TAG
FROM php:${PHP_BASEIMAGE_TAG}

WORKDIR /work

RUN apt update -y && \
  apt install -y \
  git \
  build-essential \
  autoconf \
  unzip \
  zlib1g-dev

COPY --from=composer /usr/bin/composer /usr/bin/composer

COPY --from=ghcr.io/vivion-inc/grpc-docker:php8.2-pecl-grpc1.78.0-bookworm /usr/local/lib/php/extensions/grpc.so /tmp/grpc.so

RUN mv /tmp/grpc.so $(php-config --extension-dir)/grpc.so && \
  pecl install protobuf && \
  docker-php-ext-enable grpc protobuf

RUN git clone --recurse-submodules -b v1.78.0 --depth 1 --shallow-submodules https://github.com/grpc/grpc
RUN cd grpc/examples/php && \
  composer config policy.advisories.block false && \
  composer install
