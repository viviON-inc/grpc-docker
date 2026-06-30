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

# NOTE: grpc-1.75.0 のソース (src/php/ext/grpc/call.c) は PHP 8.5 で
# ヘッダ宣言が無くなった zend_exception_get_default() を使用している。
# Debian trixie の GCC 14+ では -Wimplicit-function-declaration /
# -Wint-conversion がデフォルトでエラーに昇格するためビルドが失敗する
# (bookworm の GCC 12 では警告止まりで通る)。上流 grpc 側の非互換を
# 回避するため、当該診断を警告に戻してビルドを通す。
RUN MAKEFLAGS="-j $(nproc)" \
    CFLAGS="-Wno-implicit-function-declaration -Wno-int-conversion" \
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
