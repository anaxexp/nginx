location ~ ^/\.healthz$ {
    {{ if not (getenv "NGINX_ENABLE_HEALTHZ_LOGS") }}
    access_log off;
    {{ end }}
    return 204;
}
location /nginx-health {
    stub_status;
    allow 127.0.0.1;
    deny all;
    access_log /var/log/nginx/access.log  main if=$isNot2xx;
}