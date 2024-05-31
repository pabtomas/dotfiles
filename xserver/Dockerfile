ARG NGINX_LAYER_IMG
FROM ${NGINX_LAYER_IMG}

ARG CHECK_ENTRYPOINT_PATH
ARG ETC_NGINX_CONFD_PATH
ARG ETC_NGINX_PATH
ARG SPACEPORN_RELAY_IP
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
    cat << TEMPLATING > "${ETC_NGINX_PATH}/nginx.conf"
user root;

# Enables the use of JIT for regular expressions to speed-up their processing.
pcre_jit on;

error_log ${VAR_LOG_NGINX_PATH}/error.log info;
error_log stderr;

# Includes files with directives to load dynamic modules.
include /etc/nginx/modules/*.conf;

# Include files with config snippets into the root context.
include /etc/nginx/conf.d/*.conf;

events {
    worker_connections 1024;
}

http {
    client_body_temp_path /tmp;
    proxy_temp_path       /tmp;
    fastcgi_temp_path     /tmp;
    uwsgi_temp_path       /tmp;
    scgi_temp_path        /tmp;
}

daemon off;
pid /run/nginx.pid;
TEMPLATING
    cat << TEMPLATING > "${ETC_NGINX_CONFD_PATH}/stream.conf"
stream {
    # Includes virtual TCP hosts configs.
    include /etc/nginx/conf.d/stream/*.conf;
}
TEMPLATING
    mkdir -p "${ETC_NGINX_CONFD_PATH}/stream"
    cat << TEMPLATING > "${ETC_NGINX_CONFD_PATH}/stream/xserver.conf"
log_format custom_stream '\$remote_addr [\$time_local] '
                         '\$protocol \$status \$bytes_sent \$bytes_received '
                         '\$session_time "\$upstream_addr" '
                         '"\$upstream_bytes_sent" "\$upstream_bytes_received" "\$upstream_connect_time"';

access_log ${VAR_LOG_NGINX_PATH}/access.log custom_stream;

server {
    listen ${XSERVER_PORT};
    allow ${SPACEPORN_RELAY_IP};
    deny all;
    proxy_pass unix:${XSERVER_SOCKET_PATH};
}
TEMPLATING
    _apk="$(command -v apk)"
    cat << TEMPLATING >> "${CHECK_ENTRYPOINT_PATH}"
#! /bin/sh

main ()
{
  set -eux

  # check packages are available
  [ -n "\$(${_apk} info -q -L nginx-mod-stream)" ]

  # check Xserver socket is mounted
  [ -S "${XSERVER_SOCKET_PATH}" ]
}

main
TEMPLATING
    chmod 0700 "${CHECK_ENTRYPOINT_PATH}"
    unset http_proxy https_proxy
END_OF_RUN
