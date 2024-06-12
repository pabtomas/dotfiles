ARG SOCAT_LAYER_IMG
FROM ${SOCAT_LAYER_IMG}

ARG ENTRYPOINTD_PATH
ARG LOG_ID
ARG TMP_XSERVER_SOCKETS_PATH
ARG XSERVER_IP
ARG XSERVER_PORT
ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY:-}"
    export https_proxy="${HTTPS_PROXY:-}"
    _socat="$(command -v socat)"
    socat_entrypoint="${ENTRYPOINTD_PATH}/99socat.sh"
    cat << TEMPLATING > "${socat_entrypoint}"
#! /bin/sh

main ()
{
  set -eux

  exec ${_socat} -d3 -lf /var/log/socat.${LOG_ID}.log UNIX-LISTEN:${TMP_XSERVER_SOCKETS_PATH}/X0,reuseaddr,unlink-early,user=root,group=root,mode=770 TCP:${XSERVER_IP}:${XSERVER_PORT}
}

main
TEMPLATING
    chmod 0700 "${socat_entrypoint}"
    unset http_proxy https_proxy
END_OF_RUN
