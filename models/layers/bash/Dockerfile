ARG BASH_ENTRYPOINT_LAYER_IMG
FROM ${BASH_ENTRYPOINT_LAYER_IMG}

COPY etc/ /etc/

ARG BASH_ALIASES_PATH
ARG BASH_COMPLETION_PATH
ARG BASH_THEME_PATH
ARG CHECK_ENTRYPOINT_PATH
ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY:-}"
    export https_proxy="${HTTPS_PROXY:-}"
    apk update
    apk add --no-cache bash-completion coreutils diffutils tree less
    mkdir -p "${BASH_ALIASES_PATH}" "${BASH_COMPLETION_PATH}"
    sed -i "s@^\(root:.*:\)[^:]\+\$@\1$(command -v bash)@" /etc/passwd
    cat << TEMPLATING >> "$(dirname "${BASH_ALIASES_PATH}")/$(basename -s '.d' "${BASH_ALIASES_PATH}").sh"
main ()
{
  unalias -a

  if [ -d ${BASH_ALIASES_PATH} ]
  then
    for file in ${BASH_ALIASES_PATH}/*.sh
    do
      if [ -r "\${file}" ]
      then
        . "\${file}"
      fi
    done
    unset file
  fi
}

main
TEMPLATING
    cat << TEMPLATING >> "$(dirname "${BASH_COMPLETION_PATH}")/$(basename -s '.d' "${BASH_COMPLETION_PATH}").sh"
main ()
{
  if [ -d ${BASH_COMPLETION_PATH} ]
  then
    for file in ${BASH_COMPLETION_PATH}/*.sh
    do
      if [ -r "\${file}" ]
      then
        . "\${file}"
      fi
    done
    unset file
  fi
}

main
TEMPLATING
    cat << TEMPLATING >> "$(dirname "${BASH_THEME_PATH}")/$(basename -s '.d' "${BASH_THEME_PATH}").sh"
main ()
{
  if [ -d ${BASH_THEME_PATH} ]
  then
    for file in ${BASH_THEME_PATH}/*.sh
    do
      if [ -r "\${file}" ]
      then
        . "\${file}"
      fi
    done
    unset file
  fi
}

main
TEMPLATING
    _apk="$(command -v apk)"
    _bash="$(command -v bash)"
    _less="$(command -v less)"
    _tree="$(command -v tree)"
    cat << TEMPLATING > "${CHECK_ENTRYPOINT_PATH}"
#! /bin/sh

main ()
{
  set -eux

  # check bash is available
  ${_bash} --version

  # check less & tree availability
  ${_less} --version
  ${_tree} --version

  # check utils packages are available
  [ -n "\$(${_apk} info -q -L bash-completion)" ]
  [ -n "\$(${_apk} info -q -L coreutils)" ]
  [ -n "\$(${_apk} info -q -L diffutils)" ]
}

main
TEMPLATING
    chmod 0700 "${CHECK_ENTRYPOINT_PATH}"
    unset http_proxy https_proxy
END_OF_RUN

ARG ENTRYPOINT_PATH
ENV ENTRYPOINT_PATH ${ENTRYPOINT_PATH}
ENTRYPOINT ${ENTRYPOINT_PATH}
