ARG BASH_IMG
FROM ${BASH_IMG}

ARG NET
ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG WORKSPACES_PATH

RUN <<END_OF_RUN
    set -eux
    if [ -n "${HTTP_PROXY}" ]; then export http_proxy="${HTTP_PROXY}"; fi
    if [ -n "${HTTPS_PROXY}" ]; then export https_proxy="${HTTPS_PROXY}"; fi
    apk add --no-cache git tig vim ripgrep openssh-server
    cat << TEMPLATING > "/etc/ssh/sshd_config.d/${NET}.conf"
PasswordAuthentication no
TEMPLATING
    ssh-keygen -A
    entrypoint='/docker_entrypoint.sh'
    cat << TEMPLATING > "${entrypoint}"
#!/bin/sh
exec /usr/sbin/sshd -D -e
TEMPLATING
    chmod 0700 "${entrypoint}"
    if [ -n "${HTTP_PROXY}" ]; then unset http_proxy; fi
    if [ -n "${HTTPS_PROXY}" ]; then unset https_proxy; fi
END_OF_RUN

ENTRYPOINT ["/docker_entrypoint.sh"]

EXPOSE 22
