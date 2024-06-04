ARG SSHD_LAYER_IMG
FROM ${SSHD_LAYER_IMG}

ARG CHECK_ENTRYPOINT_PATH
ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY:-}"
    export https_proxy="${HTTPS_PROXY:-}"
    pkg='coreutils-doc diffutils-doc findutils-doc'
    pkg="${pkg} bash-doc dash-doc"
    pkg="${pkg} curl-doc wget-doc"
    pkg="${pkg} tree-doc less-doc jq-doc"
    pkg="${pkg} docker-doc"
    pkg="${pkg} nginx-doc openssh-doc socat-doc"
    pkg="${pkg} git-doc tig-doc ripgrep-doc"
    pkg="${pkg} figlet-doc"
    pkg="${pkg} pass-doc gnupg-doc"
    pkg="${pkg} tmux-doc vim-doc"
    pkg="${pkg} bats-doc shellcheck-doc"
    pkg="${pkg} spectrwm-doc"
    pkg="${pkg} cronie-doc man-db-doc"
    apk add --no-cache man-db man-pages ${pkg}
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
  for _pkg in ${pkg}
  do
    ${_apk} info --installed "\${_pkg}"
  done
}

main
TEMPLATING
    chmod 0700 "${CHECK_ENTRYPOINT_PATH}"
    unset http_proxy https_proxy
END_OF_RUN

COPY etc/ /etc/
