ARG BASH_COMPONENT_IMG
FROM ${BASH_COMPONENT_IMG}

ARG ENTRYPOINT_PATH
ARG OPT_SCRIPTS_PATH
ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY}"
    export https_proxy="${HTTPS_PROXY}"
    apk update
    apk add --no-cache openssh-server
    mkdir -p "${OPT_SCRIPTS_PATH}"
    ssh-keygen -A
    _sshd="$(command -v sshd)"
    cat << TEMPLATING > "${ENTRYPOINT_PATH}"
#!/bin/sh
exec ${_sshd} -D -e
TEMPLATING
    chmod 0700 "${ENTRYPOINT_PATH}"
    unset http_proxy https_proxy
END_OF_RUN

COPY etc/ /etc/

ENV ENTRYPOINT_PATH ${ENTRYPOINT_PATH}
ENTRYPOINT ${ENTRYPOINT_PATH}

EXPOSE 22
