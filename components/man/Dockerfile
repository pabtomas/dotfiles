ARG SSHD_COMPONENT_IMG
FROM ${SSHD_COMPONENT_IMG}

ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY}"
    export https_proxy="${HTTPS_PROXY}"
    apk add --no-cache mandoc man-pages \
      coreutils-doc bash-doc dash-doc \
      curl-doc wget-doc jq-doc \
      docker-doc \
      nginx-doc openssh-doc \
      git-doc tig-doc ripgrep-doc \
      figlet-doc \
      pass-doc \
      tmux-doc vim-doc \
      bats-doc shellcheck-doc \
      cronie-doc
    unset http_proxy https_proxy
END_OF_RUN

COPY etc/ /etc/
