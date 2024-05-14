ARG WORKSPACES_COMPONENT_IMG
FROM ${WORKSPACES_COMPONENT_IMG}

ARG NERDTREE_URL
ARG POLYGLOT_URL
ARG RAINBOW_URL
ARG UNDOTREE_URL
ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY}"
    export https_proxy="${HTTPS_PROXY}"
    apk add --no-cache --virtual __install_plugins git
    git clone --depth=1 "${NERDTREE_URL}" /root/.vim/pack/plugins/start/nerdtree
    git clone --depth=1 "${POLYGLOT_URL}" /root/.vim/pack/plugins/start/vim-polyglot
    git clone --depth=1 "${RAINBOW_URL}" /root/.vim/pack/plugins/start/rainbow
    git clone --depth=1 "${UNDOTREE_URL}" /root/.vim/pack/plugins/start/undotree
    apk del __install_plugins
    apk add --no-cache gvim
    mkdir -p /root/.vim/
    unset http_proxy https_proxy
END_OF_RUN

COPY .vimrc /root/
COPY etc/ /etc/

CMD ["vim", "--version"]
