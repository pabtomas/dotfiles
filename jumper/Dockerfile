ARG BASH_IMG

FROM ${BASH_IMG}

ARG CONTROLLER_ID
ARG HOSTNAME
ARG NET
ARG OPT_SSH_PATH
ARG SSH_ROOT_PATH
ARG UNPRIVILEGED_USER
ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    if [ -n "${HTTP_PROXY}" ]; then export http_proxy="${HTTP_PROXY}"; fi
    if [ -n "${HTTPS_PROXY}" ]; then export https_proxy="${HTTPS_PROXY}"; fi
    apk add --no-cache openssh-client
    mkdir -p "${SSH_ROOT_PATH}" "${OPT_SSH_PATH}"
    key_path="${SSH_ROOT_PATH}/id_rsa"
    ssh-keygen -q -t rsa -N '' -f "${key_path}"
    cat << TEMPLATING > "${SSH_ROOT_PATH}/config"
HOST proxy
  USER ${UNPRIVILEGED_USER}

HOST *
  USER root
TEMPLATING
    cat << TEMPLATING > "/etc/ssh/ssh_config.d/${NET}.conf"
StrictHostKeyChecking accept-new
TEMPLATING
    cp "${key_path}.pub" "${OPT_SSH_PATH}/authorized_keys"
    cat << TEMPLATING > /etc/profile.d/99completion.sh
_ssh ()
{
  declare -a -g COMPREPLY
  local cache_dir cache docker_cmd
  cache_dir='/root/.cache'
  cache="\${cache_dir}/99completion"
  readonly cache_dir cache
  mkdir -p "\${cache_dir}"
  if [[ \$(( "\$(date '+%s')" - "\$(stat -c '%Y' "\${cache}" 2> /dev/null || printf '0\n')" )) -gt 15 ]]
  then
    docker_cmd="docker network inspect -f '{{ range .Containers }}{{ printf \" %s \" .Name }}{{ end }}' '${NET}'"
    ssh '${CONTROLLER_ID}' "\${docker_cmd}" 2> /dev/null | sed 's@\s${HOSTNAME}\s@@' > "\${cache}"
  fi
  COMPREPLY=( \$(compgen -W "\$(<"\${cache}")" -- "\${COMP_WORDS["\${COMP_CWORD}"]}" ) )
}
complete -F _ssh ssh
TEMPLATING
    entrypoint='/docker_entrypoint.sh'
    cat << TEMPLATING > "${entrypoint}"
#!/bin/sh
exec /usr/local/bin/bash -l
TEMPLATING
    chmod 0700 "${entrypoint}"
    if [ -n "${HTTP_PROXY}" ]; then unset http_proxy; fi
    if [ -n "${HTTPS_PROXY}" ]; then unset https_proxy; fi
END_OF_RUN

ENTRYPOINT ["/docker_entrypoint.sh"]
