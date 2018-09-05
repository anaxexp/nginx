FROM anaxexp/alpine:3.8-2.1.0

ARG NGINX_VER

ENV NGINX_VER="${NGINX_VER}" \
    NGINX_UP_VER="0.9.1" \
    MOD_PAGESPEED_VER=1.13.35.2 \
    NGX_PAGESPEED_VER=1.13.35.2 \
    APP_ROOT="/var/www/html" \
    FILES_DIR="/mnt/files" \
    NGINX_VHOST_PRESET="html" \
    CONSUL_VERSION=0.7.5 \
    CONSUL_CHECKSUM=40ce7175535551882ecdff21fdd276cef6eaab96be8a8260e0599fadb6f1f5b8 \
    CONSUL_TEMPLATE_VERSION=0.18.3 \
    CONSUL_TEMPLATE_CHECKSUM=caf6018d7489d97d6cc2a1ac5f1cbd574c6db4cd61ed04b22b8db7b4bde64542 \
    DEHYDRATED_VERSION=v0.3.1 \
    JQ_VERSION=1.5

RUN set -ex; \
    \
    addgroup -S nginx; \
    adduser -S -D -H -h /var/cache/nginx -s /sbin/nologin -G nginx nginx; \
    \
	addgroup -g 1000 -S anaxexp; \
	adduser -u 1000 -D -S -s /bin/bash -G anaxexp anaxexp; \
	sed -i '/^anaxexp/s/!/*/' /etc/shadow; \
	echo "PS1='\w\$ '" >> /home/anaxexp/.bashrc; \
    \
    apk add --update --no-cache -t .tools \
        findutils \
        make \
        nghttp2 \
        sudo; \
    \
    apk add --update --no-cache -t .nginx-build-deps \
        apr-dev \
        apr-util-dev \
        build-base \
        gd-dev \
        geoip-dev\
        git \
        gnupg \
        gperf \
        icu-dev \
        libjpeg-turbo-dev \
        libpng-dev \
        libressl-dev \
        libtool \
        libxslt-dev \
        linux-headers \
        pcre-dev \
        zlib-dev; \
    \
    # Get ngx pagespeed module.
    git clone -b "v${NGX_PAGESPEED_VER}-stable" \
          --recurse-submodules \
          --shallow-submodules \
          --depth=1 \
          -c advice.detachedHead=false \
          -j$(getconf _NPROCESSORS_ONLN) \
          https://github.com/apache/incubator-pagespeed-ngx.git \
          /tmp/ngxpagespeed; \
    \
    # Get psol for alpine.
    url="https://github.com/anaxexp/nginx-alpine-psol/releases/download/${MOD_PAGESPEED_VER}/psol.tar.gz"; \
    wget -qO- "${url}" | tar xz -C /tmp/ngxpagespeed; \
    \
    # Get ngx uploadprogress module.
    mkdir -p /tmp/ngxuploadprogress; \
    url="https://github.com/masterzen/nginx-upload-progress-module/archive/v${NGINX_UP_VER}.tar.gz"; \
    wget -qO- "${url}" | tar xz --strip-components=1 -C /tmp/ngxuploadprogress; \
    \
    # Download nginx.
    curl -fSL "https://nginx.org/download/nginx-${NGINX_VER}.tar.gz" -o /tmp/nginx.tar.gz; \
    curl -fSL "https://nginx.org/download/nginx-${NGINX_VER}.tar.gz.asc"  -o /tmp/nginx.tar.gz.asc; \
    GPG_KEYS=B0F4253373F8F6F510D42178520A9993A1C052F8 gpg_verify /tmp/nginx.tar.gz.asc /tmp/nginx.tar.gz; \
    tar zxf /tmp/nginx.tar.gz -C /tmp; \
    \
    cd "/tmp/nginx-${NGINX_VER}"; \
    ./configure \
        --prefix=/usr/share/nginx \
        --sbin-path=/usr/sbin/nginx \
        --modules-path=/usr/lib/nginx/modules \
        --conf-path=/etc/nginx/nginx.conf \
        --pid-path=/var/run/nginx/nginx.pid \
        --lock-path=/var/run/nginx/nginx.lock \
        --http-client-body-temp-path=/var/cache/nginx/client_temp \
        --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
        --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
        --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
        --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
        --user=nginx \
        --group=nginx \
        --with-compat \
        --with-file-aio \
        --with-http_addition_module \
        --with-http_auth_request_module \
        --with-http_dav_module \
        --with-http_flv_module \
        --with-http_geoip_module \
        --with-http_gunzip_module \
        --with-http_gzip_static_module \
		--with-http_image_filter_module=dynamic \
        --with-http_mp4_module \
        --with-http_random_index_module \
        --with-http_realip_module \
        --with-http_secure_link_module \
		--with-http_slice_module \
        --with-http_ssl_module \
        --with-http_stub_status_module \
        --with-http_sub_module \
        --with-http_v2_module \
		--with-http_xslt_module=dynamic \
        --with-ipv6 \
        --with-ld-opt="-Wl,-z,relro,--start-group -lapr-1 -laprutil-1 -licudata -licuuc -lpng -lturbojpeg -ljpeg" \
        --with-mail \
        --with-mail_ssl_module \
        --with-pcre-jit \
        --with-stream \
        --with-stream_ssl_module \
		--with-stream_ssl_preread_module \
		--with-stream_realip_module \
		--with-stream_geoip_module=dynamic \
        --with-threads \
        --add-module=/tmp/ngxuploadprogress \
        --add-module=/tmp/ngxpagespeed; \
    \
    make -j$(getconf _NPROCESSORS_ONLN); \
    make install; \
    \
    install -g anaxexp -o anaxexp -d \
        "${APP_ROOT}" \
        "${FILES_DIR}" \
        /etc/nginx/conf.d \
        /var/cache/nginx \
        /var/lib/nginx; \
    \
    touch /etc/nginx/upstream.conf; \
    chown -R anaxexp:anaxexp /etc/nginx; \
    \
    install -g nginx -o nginx -d \
        /var/cache/ngx_pagespeed \
        /pagespeed_static \
        /ngx_pagespeed_beacon; \
    \
    install -m 400 -d /etc/nginx/pki; \
    \
    strip /usr/sbin/nginx*; \
    strip /usr/lib/nginx/modules/*.so; \
    \
	runDeps="$( \
		scanelf --needed --nobanner --format '%n#p' /usr/sbin/nginx /usr/lib/nginx/modules/*.so /tmp/envsubst \
			| tr ',' '\n' \
			| sort -u \
			| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
	)"; \
	apk add --no-cache --virtual .nginx-rundeps $runDeps; \
    \
    # Script to fix volumes permissions via sudo.
    echo "find ${APP_ROOT} ${FILES_DIR} -maxdepth 0 -uid 0 -type d -exec chown anaxexp:anaxexp {} +" > /usr/local/bin/init_volumes; \
    chmod +x /usr/local/bin/init_volumes; \
    \
    { \
        echo -n 'anaxexp ALL=(root) NOPASSWD:SETENV: ' ; \
        echo -n '/usr/local/bin/init_volumes, ' ; \
        echo '/usr/sbin/nginx' ; \
    } | tee /etc/sudoers.d/anaxexp; \
    \
    # Cleanup
    apk del --purge .nginx-build-deps; \
    rm -rf /tmp/*; \
    rm -rf /var/cache/apk/*

# Install Consul
# Releases at https://releases.hashicorp.com/consul
RUN curl --retry 7 --fail -vo /tmp/consul.zip "https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip" \
    && echo "${CONSUL_CHECKSUM}  /tmp/consul.zip" | sha256sum -c \
    && unzip /tmp/consul -d /usr/local/bin \
    && rm /tmp/consul.zip \
    && mkdir /config

# Create empty directories for Consul config and data
RUN mkdir -p /etc/consul \
    && mkdir -p /var/lib/consul

# Install Consul template
# Releases at https://releases.hashicorp.com/consul-template/
RUN curl --retry 7 --fail -Lso /tmp/consul-template.zip "https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip" \
    && echo "${CONSUL_TEMPLATE_CHECKSUM}  /tmp/consul-template.zip" | sha256sum -c \
    && unzip /tmp/consul-template.zip -d /usr/local/bin \
    && rm /tmp/consul-template.zip

# Add Containerpilot and set its configuration
ENV CONTAINERPILOT_VER 3.0.0
ENV CONTAINERPILOT /etc/containerpilot.json5

RUN export CONTAINERPILOT_CHECKSUM=6da4a4ab3dd92d8fd009cdb81a4d4002a90c8b7c \
    && curl -Lso /tmp/containerpilot.tar.gz \
         "https://github.com/joyent/containerpilot/releases/download/${CONTAINERPILOT_VER}/containerpilot-${CONTAINERPILOT_VER}.tar.gz" \
    && echo "${CONTAINERPILOT_CHECKSUM}  /tmp/containerpilot.tar.gz" | sha1sum -c \
    && tar zxf /tmp/containerpilot.tar.gz -C /usr/local/bin \
    && rm /tmp/containerpilot.tar.gz

# Add Dehydrated
RUN curl --retry 8 --fail -Lso /tmp/dehydrated.tar.gz "https://github.com/lukas2511/dehydrated/archive/${DEHYDRATED_VERSION}.tar.gz" \
    && tar xzf /tmp/dehydrated.tar.gz -C /tmp \
    && mv /tmp/dehydrated-0.3.1/dehydrated /usr/local/bin \
    && rm -rf /tmp/dehydrated-0.3.1

# Add jq
RUN curl --retry 8 --fail -Lso /usr/local/bin/jq "https://github.com/stedolan/jq/releases/download/jq-${JQ_VERSION}/jq-linux64" \
    && chmod a+x /usr/local/bin/jq

USER anaxexp

# Add our configuration files and scripts
RUN rm -f /etc/nginx/conf.d/default.conf
COPY etc/acme /etc/acme
COPY etc/containerpilot.json5 /etc/
COPY etc/nginx /etc/nginx/templates
COPY bin /usr/local/bin
COPY templates /etc/gotpl/
COPY docker-entrypoint.sh /

# Usable SSL certs written here
RUN mkdir -p /var/www/ssl
# Temporary/work space for keys
RUN mkdir -p /var/www/acme/ssl
# ACME challenge tokens written here
RUN mkdir -p /var/www/acme/challenge
# Consul session data written here
RUN mkdir -p /var/consul


WORKDIR $APP_ROOT
EXPOSE 80

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/local/bin/containerpilot", "sudo", "nginx"]
