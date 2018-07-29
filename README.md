# Nginx Docker Container Images

[![Build Status](https://travis-ci.org/anaxexp/nginx.svg?branch=master)](https://travis-ci.org/anaxexp/nginx)
[![Docker Pulls](https://img.shields.io/docker/pulls/anaxexperience/nginx.svg)](https://hub.docker.com/r/anaxexperience/nginx)
[![Docker Stars](https://img.shields.io/docker/stars/anaxexperience/nginx.svg)](https://hub.docker.com/r/anaxexperience/nginx)
[![Docker Layers](https://images.microbadger.com/badges/image/anaxexperience/nginx.svg)](https://microbadger.com/images/anaxexperience/nginx)

## Docker Images

❗For better reliability we release images with stability tags (`anaxexperience/nginx:1.14-X.X.X`) which correspond to [git tags](https://github.com/anaxexp/nginx/releases). We strongly recommend using images only with stability tags. 

Overview:

* All images are based on Alpine Linux
* Base image: [anaxexperience/alpine](https://github.com/anaxexp/alpine)
* [Travis CI builds](https://travis-ci.org/anaxexp/nginx) 
* [Docker Hub](https://hub.docker.com/r/anaxexperience/nginx)

Supported tags and respective `Dockerfile` links:

* `1.15`, `1`, `latest` [_(Dockerfile)_](https://github.com/anaxexp/nginx/tree/master/Dockerfile)
* `1.14` [_(Dockerfile)_](https://github.com/anaxexp/nginx/tree/master/Dockerfile)
* `1.13` [_(Dockerfile)_](https://github.com/anaxexp/nginx/tree/master/Dockerfile)

## Environment Variables

| Variable                                  | Default Value               | Description |
| ----------------------------------------- | ----------------------      | ----------- |
| `NGINX_CLIENT_BODY_BUFFER_SIZE`           | `16k`                       |             |
| `NGINX_CLIENT_BODY_TIMEOUT`               | `60s`                       |             |
| `NGINX_CLIENT_HEADER_BUFFER_SIZE`         | `4k`                        |             |
| `NGINX_CLIENT_HEADER_TIMEOUT`             | `60s`                       |             |
| `NGINX_CLIENT_MAX_BODY_SIZE`              | `32m`                       |             |
| `NGINX_CONF_INCLUDE`                      | `conf.d/*.conf`             |             |
| `NGINX_DISABLE_CACHING`                   |                             |             |
| `NGINX_ENABLE_HEALTHZ_LOGS`               |                             |             |
| `NGINX_ERROR_LOG_LEVEL`                   | `error`                     |             |
| `NGINX_GZIP`                              | `on`                        |             |
| `NGINX_GZIP_BUFFERS`                      | `16 8k`                     |             |
| `NGINX_GZIP_COMP_LEVEL`                   | `1`                         |             |
| `NGINX_GZIP_DISABLE`                      | `msie6`                     |             |
| `NGINX_GZIP_HTTP_VERSION`                 | `1.1`                       |             |
| `NGINX_GZIP_MIN_LENGTH`                   | `20`                        |             |
| `NGINX_GZIP_PROXIED`                      | `any`                       |             |
| `NGINX_GZIP_VARY`                         | `on`                        |             |
| `NGINX_HTTP2`                             |                             |             |
| `NGINX_INDEX_FILE`                        | `index.html index.htm`      |             |
| `NGINX_NO_DEFAULT_HEADERS`                |                             |             |
| `NGINX_KEEPALIVE_REQUESTS`                | `100`                       |             |
| `NGINX_KEEPALIVE_TIMEOUT`                 | `75s`                       |             |
| `NGINX_LARGE_CLIENT_HEADER_BUFFERS`       | `8 16k`                     |             |
| `NGINX_LOG_FORMAT_OVERRIDE`               |                             |             |
| `NGINX_LOG_FORMAT_SHOW_REAL_IP`           |                             |             |
| `NGINX_MULTI_ACCEPT`                      | `on`                        |             |
| `NGINX_PAGESPEED`                         | `unplugged`                 |             |
| `NGINX_PAGESPEED_ENABLE_FILTERS`          |                             |             |
| `NGINX_PAGESPEED_FILE_CACHE_PATH`         | `/var/cache/ngx_pagespeed/` |             |
| `NGINX_PAGESPEED_PRESERVE_URL_RELATIVITY` | `on`                        |             |
| `NGINX_PAGESPEED_REWRITE_LEVEL`           | `CoreFilters`               |             |
| `NGINX_PAGESPEED_STATIC_ASSET_PREFIX`     | `/pagespeed_static`         |             |
| `NGINX_RESET_TIMEDOUT_CONNECTION`         | `off`                       |             |
| `NGINX_SEND_TIMEOUT`                      | `60s`                       |             |
| `NGINX_SENDFILE`                          | `on`                        |             |
| `NGINX_SERVER_TOKENS`                     | `off`                       |             |
| `NGINX_SERVER_ROOT`                       | `/var/www/html`             |             |
| `NGINX_TCP_NODELAY`                       | `on`                        |             |
| `NGINX_TCP_NOPUSH`                        | `on`                        |             |
| `NGINX_UNDERSCORES_IN_HEADERS`            | `off`                       |             |
| `NGINX_UPLOAD_PROGRESS`                   | `uploads 1m`                |             |
| `NGINX_USER`                              | `nginx`                     |             |
| `NGINX_WORKER_CONNECTIONS`                | `1024`                      |             |
| `NGINX_WORKER_PROCESSES`                  | `auto`                      |             |

## [Installed Nginx Modules]((https://raw.githubusercontent.com/anaxexp/nginx/master/tests/nginx_modules))

## Images based on `anaxexperience/nginx`

* [anaxexperience/php-nginx](https://github.com/anaxexp/php-nginx)
* [anaxexperience/gitlab-nginx](https://github.com/anaxexp/gitlab-nginx)

## Orchestration actions

Usage:
```
make COMMAND [params ...]

commands:
    git-clone [url branch]
    git-checkout [target is_hash]
    check-ready [host max_try wait_seconds delay_seconds]
 
default params values:
    host localhost
    max_try 1
    wait_seconds 1
    delay_seconds 0
    is_hash 0
    branch ""    
```
