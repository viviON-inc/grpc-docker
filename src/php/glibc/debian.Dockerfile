ARG PHP_BASEIMAGE_TAG
FROM php:${PHP_BASEIMAGE_TAG} as build

# Install dependencies
# https://cloud.google.com/php/grpc#build-from-source
RUN apt update -y && \
    apt install -y \
        git \
        build-essential \
        autoconf \
        zlib1g-dev

ARG GRPC_VERSION
ARG GRPC_OUTPUT_PATH

# NOTE: PHP 8.5 で削除された zend_exception_get_default() を grpc が使用
# しているため、PHP 8.5 のビルドには grpc 1.78.0 以上が必要 (1.78.0 で
# PHP 8.5 対応のバージョン分岐が入った)。grpc のバージョンは GRPC_VERSION
# (build-arg) で制御する。
RUN MAKEFLAGS="-j $(nproc)" \
    pecl install grpc-${GRPC_VERSION}

RUN strip --strip-all $(php-config --extension-dir)/grpc.so && \
    mv $(php-config --extension-dir)/grpc.so ${GRPC_OUTPUT_PATH}

# Refinement
FROM php:${PHP_BASEIMAGE_TAG} as build-aux

RUN apt update -y && \
    apt install -y \
        git \
        build-essential

ARG GRPC_OUTPUT_PATH
COPY --from=build ${GRPC_OUTPUT_PATH} ${GRPC_OUTPUT_PATH}

RUN strip --strip-all ${GRPC_OUTPUT_PATH}

# Final image
FROM scratch

ARG GRPC_OUTPUT_PATH
COPY --from=build-aux ${GRPC_OUTPUT_PATH} ${GRPC_OUTPUT_PATH}

COPY ACKNOWLEDGEMENTS.txt LICENSE README.md /
