ARG BASH_IMG
ARG DOCKER_IMG

FROM ${DOCKER_IMG} as docker_img
FROM ${BASH_IMG}

ARG DOCKER_PATH
COPY --from=docker_img ${DOCKER_PATH}/docker ${DOCKER_PATH}/

ARG CACHE_PATH
ARG CACHE_COMPLETION_PATH
ARG MY_WHALE_FLEET_PATH
ARG NET
ARG DOCKER_HOST
ARG SSH_ROOT_PATH
ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    if [ -n "${HTTP_PROXY}" ]; then export http_proxy="${HTTP_PROXY}"; fi
    if [ -n "${HTTPS_PROXY}" ]; then export https_proxy="${HTTPS_PROXY}"; fi
    apk add --no-cache openssh-server
    mkdir -p "${MY_WHALE_FLEET_PATH}" "${CACHE_PATH}" "${SSH_ROOT_PATH}"
    sed -i "s@^\(root:.*:\)[^:]\+\$@\1$(command -v bash)@" /etc/passwd
    cat << TEMPLATING > /etc/profile.d/env.sh
export DOCKER_HOST=${DOCKER_HOST}
TEMPLATING
    cat << TEMPLATING > "/etc/ssh/sshd_config.d/${NET}.conf"
PasswordAuthentication no
PermitUserEnvironment yes
TEMPLATING
    docker_cmd="${DOCKER_PATH}/docker network inspect -f '{{ range .Containers }}{{ printf \" %s \" .Name }}{{ end }}' '${NET}' > '${CACHE_COMPLETION_PATH}'"
    cat << TEMPLATING > /etc/crontabs/root
* * * * * export DOCKER_HOST=${DOCKER_HOST}; ${docker_cmd} 2>> /var/log/cron.log
TEMPLATING
    ssh-keygen -A
    entrypoint='/docker_entrypoint.sh'
    cat << TEMPLATING > "${entrypoint}"
#!/bin/sh
export DOCKER_HOST=${DOCKER_HOST}
${docker_cmd} 2> /dev/null
unset DOCKER_HOST
/usr/sbin/sshd -D -e &
/usr/sbin/crond &
wait
TEMPLATING
    chmod 0700 "${entrypoint}"
    if [ -n "${HTTP_PROXY}" ]; then unset http_proxy; fi
    if [ -n "${HTTPS_PROXY}" ]; then unset https_proxy; fi
END_OF_RUN

ENTRYPOINT ["/docker_entrypoint.sh"]

EXPOSE 22
