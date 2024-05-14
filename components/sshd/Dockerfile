ARG BASH_COMPONENT_IMG
FROM ${BASH_COMPONENT_IMG}

ARG ENTRYPOINTD_PATH
ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY}"
    export https_proxy="${HTTPS_PROXY}"
    apk add --no-cache openssh-server
    ssh-keygen -A
    _sshd="$(command -v sshd)"
    sshd_entrypoint="${ENTRYPOINTD_PATH}/99sshd.sh"
    cat << TEMPLATING > "${sshd_entrypoint}"
#! /bin/sh -eux

exec ${_sshd} -D -e
TEMPLATING
    chmod 0700 "${sshd_entrypoint}"
    unset http_proxy https_proxy
END_OF_RUN

COPY etc/ /etc/

EXPOSE 22
