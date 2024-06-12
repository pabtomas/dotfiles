ARG BASH_LAYER_IMG
FROM ${BASH_LAYER_IMG}

ARG CHECK_ENTRYPOINT_PATH
ARG ENTRYPOINTD_PATH
ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG SSH_PORT

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY:-}"
    export https_proxy="${HTTPS_PROXY:-}"
    apk add --no-cache openssh-server
    ssh-keygen -A
    _sshd="$(command -v sshd)"
    cat << TEMPLATING >> "${CHECK_ENTRYPOINT_PATH}"
#! /bin/sh

main ()
{
  set -eux

  # check sshd availability
  ${_sshd} -V
}

main
TEMPLATING
    sshd_entrypoint="${ENTRYPOINTD_PATH}/99sshd.sh"
    cat << TEMPLATING > "${sshd_entrypoint}"
#! /bin/sh

main ()
{
  set -eux
  exec ${_sshd} -D -e -p ${SSH_PORT}
}

main
TEMPLATING
    chmod 0700 "${sshd_entrypoint}" "${CHECK_ENTRYPOINT_PATH}"
    unset http_proxy https_proxy
END_OF_RUN

COPY etc/ /etc/
