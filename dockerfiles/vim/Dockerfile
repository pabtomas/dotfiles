ARG WORKSPACES_LAYER_IMG
FROM ${WORKSPACES_LAYER_IMG}

ARG CHECK_ENTRYPOINT_PATH
ARG NERDTREE_URL
ARG POLYGLOT_URL
ARG RAINBOW_URL
ARG UNDOTREE_URL
ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY:-}"
    export https_proxy="${HTTPS_PROXY:-}"
    apk add --no-cache --virtual __install_plugins git
    git clone --depth 1 "${NERDTREE_URL}" /root/.vim/pack/plugins/start/nerdtree
    git clone --depth 1 "${POLYGLOT_URL}" /root/.vim/pack/plugins/start/vim-polyglot
    git clone --depth 1 "${RAINBOW_URL}" /root/.vim/pack/plugins/start/rainbow
    git clone --depth 1 "${UNDOTREE_URL}" /root/.vim/pack/plugins/start/undotree
    apk del __install_plugins
    apk add --no-cache gvim
    mkdir -p /root/.vim/
    _grep="$(command -v grep)"
    _vim="$(command -v vim)"
    cat << TEMPLATING >> "${CHECK_ENTRYPOINT_PATH}"
#! /bin/sh

main ()
{
  set -eux

  # check vim availability and clientserver feature
  ${_vim} --version | ${_grep} '+clientserver'
}

main
TEMPLATING
    chmod 0700 "${CHECK_ENTRYPOINT_PATH}"
    unset http_proxy https_proxy
END_OF_RUN

COPY .vimrc /root/
COPY etc/ /etc/
