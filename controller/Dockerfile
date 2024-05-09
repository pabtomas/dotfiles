ARG BASH_IMG
ARG DOCKER_IMG

FROM ${DOCKER_IMG} as docker_img
FROM ${BASH_IMG}

ARG DOCKER_PATH
COPY --from=docker_img ${DOCKER_PATH}/docker ${DOCKER_PATH}/

ARG ENTRYPOINT_PATH
ARG NET
ARG OPT_SCRIPTS_PATH
ARG TCP_DOCKER_HOST
ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY}"
    export https_proxy="${HTTPS_PROXY}"
    apk add --no-cache openssh-server
    mkdir -p "${OPT_SCRIPTS_PATH}"
    sed -i "s@^\(root:.*:\)[^:]\+\$@\1$(command -v bash)@" /etc/passwd
    cat << TEMPLATING > /etc/profile.d/env.sh
export DOCKER_HOST=${TCP_DOCKER_HOST}
TEMPLATING
    cat << TEMPLATING > "/etc/ssh/sshd_config.d/${NET}.conf"
PasswordAuthentication no
PermitUserEnvironment yes
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
