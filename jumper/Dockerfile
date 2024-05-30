ARG TMUX_COMPONENT_IMG

FROM ${TMUX_COMPONENT_IMG}

ARG BASH_COMPLETION_PATH
ARG BASH_THEME_PATH
ARG CHECK_ENTRYPOINT_PATH
ARG COMPLETION_PATH
ARG _COMPOSE_FILE
ARG CONTROLLER_ID
ARG ENTRYPOINTD_PATH
ARG HOSTNAME
ARG OPT_SCRIPTS_PATH
ARG OPT_SSH_PATH
ARG NET
ARG NET_PFX
ARG SSH_ROOT_PATH
ARG TCP_DOCKER_TARGET
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
    _cat="$(command -v cat)"
    _head="$(command -v head)"
    _shuf="$(command -v shuf)"
    _tr="$(command -v tr)"
    _yes="$(command -v yes)"
    login_entrypoint="${ENTRYPOINTD_PATH}/99login.sh"
    cat << TEMPLATING > "${login_entrypoint}"
#! /bin/sh

main ()
{
  set -eux

  themes="\$(${_yes} "\$(printf '%s\n' '21' '27' '33' '39' '45' '46' '47' '48' '49' '50' '51' '82' '93' '118' '129' '154' '165' '190' '196' '197' '198' '199' '200' '201' '202' '208' '214' '220' '244' '15' | ${_shuf})" | ${_head} -n 256 | ${_tr} '\n' ' ')"
  readonly themes

  ${_cat} << __TEMPLATING >> ${BASH_THEME_PATH}/99themes.sh
main ()
{
  ID="\\\$(hostname -i | tr ' ' '\n' | grep '^${NET_PFX}')"
  PROMPT_THEME="\\\$(printf '%s\n' \${themes} | sed "\\\${ID##*.}q;d" )"
  THEME="\\\$(printf '%s\n' \${themes} | sed '1q;d' )"

  export PROMPT_THEME THEME
}

main
__TEMPLATING

  exec ${_bash} -l
}

main
TEMPLATING
    _hostname="$(command -v hostname)"
    _nc="$(command -v nc)"
    _ssh="$(command -v ssh)"
    _yq="$(command -v yq)"
    cat << TEMPLATING >> "${CHECK_ENTRYPOINT_PATH}"
#! /bin/sh

main ()
{
  set -eux

  # check ssh availability
  ${_ssh} -V

  # check hosts are available through ssh
  for host in \$(printf '%s\n' "${_COMPOSE_FILE}" | ${_yq} '.services | to_entries[] | select(.value.networks | to_entries[] | select(.key=="${NET}")) | .value.hostname')
  do
    if [ "\${host}" != "\$(${_hostname})" ]; then ${_nc} -z -v \${host} 22; fi
  done
}

main
TEMPLATING
    chmod 0700 "${login_entrypoint}" "${CHECK_ENTRYPOINT_PATH}"
    unset http_proxy https_proxy
END_OF_RUN

COPY --chmod=0644 etc/ /etc/
COPY --chmod=0644 root/ /root/
