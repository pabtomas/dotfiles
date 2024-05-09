ARG BASH_IMG
FROM ${BASH_IMG}

ARG ENTRYPOINT_PATH
ARG NET
ARG OPT_SCRIPTS_PATH
ARG WORKSPACES_PATH
ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY}"
    export https_proxy="${HTTPS_PROXY}"
    apk add --no-cache git tig vim ripgrep openssh-server
    mkdir -p "${WORKSPACES_PATH}" "${OPT_SCRIPTS_PATH}"
    sed -i "s@^\(root:.*:\)[^:]\+\$@\1$(command -v bash)@" /etc/passwd
    cat << TEMPLATING > "/etc/ssh/sshd_config.d/${NET}.conf"
PasswordAuthentication no
TEMPLATING
    ssh-keygen -A
    _sshd="$(command -v sshd)"
    cat << TEMPLATING > "${ENTRYPOINT_PATH}"
#!/bin/sh
exec ${_sshd} -D -e
TEMPLATING
    chmod 0700 "${ENTRYPOINT_PATH}"
    unset http_proxy https_proxy
END_OF_RUN

ENV ENTRYPOINT_PATH ${ENTRYPOINT_PATH}
ENTRYPOINT ${ENTRYPOINT_PATH}

EXPOSE 22

WORKDIR ${WORKSPACES_PATH}
