ARG SOCAT_COMPONENT_IMG
FROM ${SOCAT_COMPONENT_IMG}

ARG ENTRYPOINTD_PATH
ARG XSERVER_IP
ARG XSERVER_PORT
ARG XSERVER_SOCKET_PATH
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

  exec ${_socat} -d3 -lf /var/log/socat.log -lh -v UNIX-LISTEN:${XSERVER_SOCKET_PATH},fork,reuseaddr,unlink-early,user=root,group=root,mode=770 TCP:${XSERVER_IP}:${XSERVER_PORT}
}

main
TEMPLATING
    chmod 0700 "${socat_entrypoint}"
    unset http_proxy https_proxy
END_OF_RUN
