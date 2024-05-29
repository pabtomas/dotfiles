ARG SSHD_COMPONENT_IMG
FROM ${SSHD_COMPONENT_IMG}

ARG CHECK_ENTRYPOINT_PATH
ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY:-}"
    export https_proxy="${HTTPS_PROXY:-}"
    docs='
coreutils-doc bash-doc dash-doc
curl-doc wget-doc jq-doc
tree-doc less-doc
docker-doc
nginx-doc openssh-doc socat-doc
git-doc tig-doc ripgrep-doc
figlet-doc
pass-doc gnupg-doc
tmux-doc vim-doc
bats-doc shellcheck-doc
cronie-doc
'
    apk add --no-cache mandoc man-pages ${docs}
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
