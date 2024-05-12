ARG TMUX_COMPONENT_IMG

FROM ${TMUX_COMPONENT_IMG}

ARG BASH_COMPLETION_PATH
ARG COMPLETION_PATH
ARG CONTROLLER_ID
ARG ENTRYPOINT_PATH
ARG HOSTNAME
ARG OPT_SCRIPTS_PATH
ARG OPT_SSH_PATH
ARG SSH_ROOT_PATH
ARG TCP_DOCKER_HOST
ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY}"
    export https_proxy="${HTTPS_PROXY}"
    apk add --no-cache openssh-client
    mkdir -p "${SSH_ROOT_PATH}" "${OPT_SSH_PATH}" "${OPT_SCRIPTS_PATH}"
    key_path="${SSH_ROOT_PATH}/id_rsa"
    ssh-keygen -q -t rsa -N '' -f "${key_path}"
    cp "${key_path}.pub" "${OPT_SSH_PATH}/authorized_keys"
    ssh_environment="${OPT_SSH_PATH}/environment"
    cat << TEMPLATING > "${ssh_environment}"
DOCKER_HOST=${TCP_DOCKER_HOST}
TEMPLATING
    chmod 0640 "${ssh_environment}"
    cat << TEMPLATING > "${BASH_COMPLETION_PATH}/99ssh.sh"
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
    unset http_proxy https_proxy
END_OF_RUN

COPY etc/ /etc/
COPY root/ /root/

ENV ENTRYPOINT_PATH ${ENTRYPOINT_PATH}
ENTRYPOINT ${ENTRYPOINT_PATH}
