ARG PROXY_COMPONENT_IMG
FROM ${PROXY_COMPONENT_IMG}

ARG APK_PATHS
ARG NGINX_DEFAULT_CONF_PATH
ARG XSERVER_PORT
ARG XSERVER_SOCKET_PATH
ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY:-}"
    export https_proxy="${HTTPS_PROXY:-}"
    rm -rf ${APK_PATHS}
    cat << TEMPLATING > "${NGINX_DEFAULT_CONF_PATH}"
server {
    server_name _;
    listen ${XSERVER_PORT} default_server;

    set \$xserversocket ${XSERVER_SOCKET_PATH};

    location / {proxy_pass unix:\$xserversocket;}
}
TEMPLATING
    unset http_proxy https_proxy
END_OF_RUN

EXPOSE ${XSERVER_PORT}
