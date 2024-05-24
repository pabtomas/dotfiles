ARG PROXY_COMPONENT_IMG
FROM ${PROXY_COMPONENT_IMG}

ARG APK_PATHS
ARG ETC_NGINX_CONFD_PATH
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
    cat << TEMPLATING > "${ETC_NGINX_CONFD_PATH}/xserver.conf"
access_log ${VAR_LOG_NGINX_PATH}/access.log combined;
error_log ${VAR_LOG_NGINX_PATH}/error.log info;
error_log stderr;
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
