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
    cat << TEMPLATING > "${ETC_NGINX_PATH}/nginx.conf"
user root;

# Set number of worker processes automatically based on number of CPU cores.
worker_processes auto;

# Enables the use of JIT for regular expressions to speed-up their processing.
pcre_jit on;

error_log ${VAR_LOG_NGINX_PATH}/error.log info;
error_log stderr;

# Includes files with directives to load dynamic modules.
include /etc/nginx/modules/*.conf;

# Include files with config snippets into the root context.
include /etc/nginx/conf.d/*.conf;

events {
    worker_connections  1024;
}

http {
    client_body_temp_path /tmp;
    proxy_temp_path /tmp;
    fastcgi_temp_path /tmp;
    uwsgi_temp_path /tmp;
    scgi_temp_path /tmp;
}

stream {
    include /etc/nginx/stream.d/*.conf;
}

daemon off;
pid /run/nginx.pid;
TEMPLATING
    cat << TEMPLATING > "${ETC_NGINX_PATH}/stream.d/xserver.conf"
log_format custom_stream '\$remote_addr > \$server_addr:\$server_port [\$time_local] \$status \$bytes_sent';

access_log ${VAR_LOG_NGINX_PATH}/access.log custom_stream;

server {
    listen 127.0.0.1:${XSERVER_PORT};
    proxy_pass xserver;
}

upstream xserver {
    server unix:${XSERVER_SOCKET_PATH};
}
TEMPLATING
    unset http_proxy https_proxy
END_OF_RUN

EXPOSE ${XSERVER_PORT}
