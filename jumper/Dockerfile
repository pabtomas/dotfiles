ARG BASH_IMG

FROM ${BASH_IMG}

ARG COMPLETION_PATH
ARG CONTROLLER_ID
ARG ENTRYPOINT_PATH
ARG HOSTNAME
ARG NET
ARG OPT_SCRIPTS_PATH
ARG OPT_SSH_PATH
ARG SSH_ROOT_PATH
ARG TCP_DOCKER_HOST
ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    if [ -n "${HTTP_PROXY}" ]; then export http_proxy="${HTTP_PROXY}"; fi
    if [ -n "${HTTPS_PROXY}" ]; then export https_proxy="${HTTPS_PROXY}"; fi
    apk add --no-cache openssh-client tmux
    mkdir -p "${SSH_ROOT_PATH}" "${OPT_SSH_PATH}" "${OPT_SCRIPTS_PATH}"
    key_path="${SSH_ROOT_PATH}/id_rsa"
    ssh-keygen -q -t rsa -N '' -f "${key_path}"
    cat << TEMPLATING > "${SSH_ROOT_PATH}/config"
HOST *
  USER root
TEMPLATING
    cat << TEMPLATING > "/etc/ssh/ssh_config.d/${NET}.conf"
StrictHostKeyChecking accept-new
TEMPLATING
    cp "${key_path}.pub" "${OPT_SSH_PATH}/authorized_keys"
    ssh_environment="${OPT_SSH_PATH}/environment"
    cat << TEMPLATING > "${ssh_environment}"
DOCKER_HOST=${TCP_DOCKER_HOST}
TEMPLATING
    chmod 0640 "${ssh_environment}"
    cat << TEMPLATING > /etc/profile.d/99completion.sh
_ssh ()
{
  declare -a -g COMPREPLY
  COMPREPLY=( \$(compgen -W "\$(grep -v '^${HOSTNAME}$' '${COMPLETION_PATH}')" -- "\${COMP_WORDS["\${COMP_CWORD}"]}" ) )
}
complete -F _ssh ssh
TEMPLATING
    _bash="$(command -v bash)"
    cat << TEMPLATING > "${ENTRYPOINT_PATH}"
#!/bin/sh
exec ${_bash} -l
TEMPLATING
    chmod 0700 "${ENTRYPOINT_PATH}"
    if [ -n "${HTTP_PROXY}" ]; then unset http_proxy; fi
    if [ -n "${HTTPS_PROXY}" ]; then unset https_proxy; fi
END_OF_RUN

ENV ENTRYPOINT_PATH ${ENTRYPOINT_PATH}
ENTRYPOINT ${ENTRYPOINT_PATH}
