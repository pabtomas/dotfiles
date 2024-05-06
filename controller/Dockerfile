ARG BASH_IMG
ARG DOCKER_IMG

FROM ${DOCKER_IMG} as docker_img
FROM ${BASH_IMG}
COPY --from=docker_img /usr/local/bin/docker /usr/local/bin/

ARG NET
ARG DOCKER_HOST
ARG SSH_ROOT
ARG USE_PROXY

RUN <<END_OF_RUN
    set -eux
    if [ -n "${USE_PROXY}" ]; then export http_proxy="${USE_PROXY}" https_proxy="${USE_PROXY}"; fi
    apk add --no-cache openssh-server
    sed -i "s@^\(root:.*:\)[^:]\+\$@\1$(command -v bash)@" /etc/passwd
    cat << TEMPLATING > /etc/profile.d/env.sh
export DOCKER_HOST=${DOCKER_HOST}
TEMPLATING
    cat << TEMPLATING > "/etc/ssh/sshd_config.d/${NET}.conf"
PasswordAuthentication no
PermitUserEnvironment yes
TEMPLATING
    ssh-keygen -A
    ENTRYPOINT='/docker_entrypoint.sh'
    cat << TEMPLATING > "${ENTRYPOINT}"
#!/bin/sh
printf 'DOCKER_HOST=${DOCKER_HOST}\n' >> ${SSH_ROOT}/environment
exec /usr/sbin/sshd -D -e
TEMPLATING
    chmod 0700 "${ENTRYPOINT}"
    if [ -n "${USE_PROXY}" ]; then unset http_proxy https_proxy; fi
END_OF_RUN

ENTRYPOINT ["/docker_entrypoint.sh"]

EXPOSE 22
