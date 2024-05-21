ARG TMUX_COMPONENT_IMG

FROM ${TMUX_COMPONENT_IMG}

ARG BASH_COMPLETION_PATH
ARG COMPLETION_PATH
ARG CONTROLLER_ID
ARG ENTRYPOINTD_PATH
ARG HOSTNAME
ARG OPT_SCRIPTS_PATH
ARG OPT_SSH_PATH
ARG NET_PFX
ARG SSH_ROOT_PATH
ARG TCP_DOCKER_HOST
ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY:-}"
    export https_proxy="${HTTPS_PROXY:-}"
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
#! /usr/bin/env bash

_ssh ()
{
  declare -a -g COMPREPLY
  COMPREPLY=( \$(compgen -W "\$(grep -v '^${HOSTNAME}$' '${COMPLETION_PATH}')" -- "\${COMP_WORDS["\${COMP_CWORD}"]}" ) )
}

complete -F _ssh ssh
TEMPLATING
    _bash="$(command -v bash)"
    login_entrypoint="${ENTRYPOINTD_PATH}/99login.sh"
    cat << TEMPLATING > "${login_entrypoint}"
#! /bin/sh

main ()
{
  set -eux

  local themes themes_sh host
  themes="\$(yes "\$(printf '%s\n' '21' '27' '33' '39' '45' '46' '47' '48' '49' '50' '51' '82' '93' '118' '129' '154' '165' '190' '196' '197' '198' '199' '200' '201' '202' '208' '214' '220' '244' '15' | shuf)" | head -n 256 | tr '\n' ' ')"
  themes_sh='/etc/profile.d/10themes.sh'
  readonly themes themes_sh

  cat << __TEMPLATING >> "\${themes_sh}"
main ()
{
  ID="\\\$(hostname -i | tr ' ' '\n' | grep '^${NET_PFX}')"
  PROMPT_THEME="\\\$(printf '%s\n' \${themes} | sed "\\\${ID##*.}q;d" )"
  THEME="\\\$(printf '%s\n' \${themes} | sed '1q;d' )"

  export PROMPT_THEME THEME
}

main
__TEMPLATING

  for host in \$(grep -v '${HOSTNAME}' '/opt/collector/opt/data/99completion')
  do
    until scp "\${themes_sh}" "\${host}:\${themes_sh}"; do :; done
  done

  exec ${_bash} -l
}

main
TEMPLATING
    chmod 0700 "${login_entrypoint}"
    unset http_proxy https_proxy
END_OF_RUN

COPY --chmod=0644 etc/ /etc/
COPY --chmod=0644 root/ /root/
