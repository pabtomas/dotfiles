ARG NGINX_COMPONENT_IMG
FROM ${NGINX_COMPONENT_IMG}

ARG APK_PATHS
ARG ETC_NGINX_CONFD_PATH
ARG ETC_NGINX_PATH
ARG VAR_LOG_NGINX_PATH
ARG XSERVER_PORT
ARG XSERVER_SOCKET_PATH
ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY:-}"
    export https_proxy="${HTTPS_PROXY:-}"
    apk add --no-cache nginx-mod-stream
    rm -rf ${APK_PATHS}
    install -d -o nginx -g nginx -m 0700 /var/lib/nginx/tmp/client_body
    cat << TEMPLATING > "${ETC_NGINX_PATH}/xserver.conf"
user root;

pcre_jit on;

events {
    worker_connections  1024;
}

log_format custom_stream '\$remote_addr > \$server_addr:\$server_port [\$time_local] '
                         '\$status \$bytes_sent '
                         'rt=\$request_time uct="\$upstream_connect_time" uht="\$upstream_header_time" urt="\$upstream_response_time"';

access_log ${VAR_LOG_NGINX_PATH}/access.log custom_stream;
error_log ${VAR_LOG_NGINX_PATH}/error.log info;
error_log stderr;

stream {
    client_max_body_size 0;
    client_body_temp_path /tmp;
    proxy_temp_path /tmp;
    fastcgi_temp_path /tmp;
    uwsgi_temp_path /tmp;
    scgi_temp_path /tmp;

    server {
        listen 127.0.0.1:${XSERVER_PORT};
        proxy_pass xserver;

    }

    upstream xserver {
        server unix:${XSERVER_SOCKET_PATH};
    }
}

daemon off;
pid /run/nginx.pid;
TEMPLATING
    unset http_proxy https_proxy
END_OF_RUN

EXPOSE ${XSERVER_PORT}
