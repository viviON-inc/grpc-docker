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
