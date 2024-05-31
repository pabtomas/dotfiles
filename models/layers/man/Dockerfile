ARG SSHD_LAYER_IMG
FROM ${SSHD_LAYER_IMG}

ARG CHECK_ENTRYPOINT_PATH
ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY:-}"
    export https_proxy="${HTTPS_PROXY:-}"
    docs='coreutils-doc diffutils-doc findutils-doc'
    docs="${docs} bash-doc dash-doc"
    docs="${docs} curl-doc wget-doc"
    docs="${docs} tree-doc less-doc jq-doc"
    docs="${docs} docker-doc"
    docs="${docs} nginx-doc openssh-doc socat-doc"
    docs="${docs} git-doc tig-doc ripgrep-doc"
    docs="${docs} figlet-doc"
    docs="${docs} pass-doc gnupg-doc"
    docs="${docs} tmux-doc vim-doc"
    docs="${docs} bats-doc shellcheck-doc"
    docs="${docs} cronie-doc man-db-doc"
    apk add --no-cache man-db man-pages ${docs}
    _apk="$(command -v apk)"
    _man="$(command -v man)"
    cat << TEMPLATING >> "${CHECK_ENTRYPOINT_PATH}"
#! /bin/sh

main ()
{
  set -eux

  # check man availability
  ${_man} --version

  # check pages availability
  for doc in ${docs}
  do
    [ -n "\$(${_apk} info -q -L "\${doc}")" ]
  done
}

main
TEMPLATING
    chmod 0700 "${CHECK_ENTRYPOINT_PATH}"
    unset http_proxy https_proxy
END_OF_RUN

COPY etc/ /etc/
