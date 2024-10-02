# grpc-docker
![example branch parameter](https://github.com/viviON-inc/grpc-docker/actions/workflows/php_server_connection_test.yml/badge.svg?branch=main)

## このリポジトリについて

gRPCをビルドしたDockerイメージを配布しています。

gRPCのPHP拡張モジュールにはビルド速度に課題があります。 (Issue. <https://github.com/grpc/grpc/issues/34278>)  
gRPCのビルド成果物のみ取得するアプローチで、  
コンテナのビルド速度を改善し、リリースのリードタイムを短縮することが本リポジトリの目的です。

※gRPC開発commumityによるイメージ管理リポジトリがあります。  
2024年10月時点で休止状態ですが、復活しましたらこちらの利用もご検討ください。  
<https://github.com/grpc/grpc-docker-library>

## 利用方法

下記を参考にCOPY, RUN命令を追記するようDockerfileを編集してください。

```Dockerfile
FROM php:8.3-fpm-bookworm

## ビルド処理を代替するためコメントアウトします。
# RUN pecl install grpc

## grpc.soを取得し、PHPの拡張モジュールディレクトリに配置します。
COPY --from=ghcr.io/vivion-inc/grpc-docker:php8.3-pecl-grpc1.66.0-bookworm /usr/local/lib/php/extensions/grpc.so /tmp/grpc.so
RUN mv /tmp/grpc.so $(php-config --extension-dir)/grpc.so && docker-php-ext-enable grpc
```

## 管理イメージ

### Target Platforms

- linux/amd64
- linux/arm64

### Repository

- `ghcr.io/vivion-inc/grpc-docker`

### Tags

#### PHP

- Tag Format
  - `<PHP Version Prefix>-<gRPC Version Infix>-<libc Environment Suffix>`

    | PHP Version Prefixes | gRPC Version Infixes | libc Environment Suffixes |
    | -------------------- | -------------------- | --------------------------|
    | php7.4-pecl          | grpc1.64.1           | glibc2.31                 |
    | php8.0-pecl          | grpc1.65.5           | bullseye                  |
    | php8.1-pecl          | grpc1.66.0           | glibc2.36                 |
    | php8.2-pecl          |                      | bookworm                  |
    | php8.3-pecl          |                      |                           |

  - Example
    - `ghcr.io/vivion-inc/grpc-docker:php8.3-pecl-grpc1.66.0-bookworm`
