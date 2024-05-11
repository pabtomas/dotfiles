ARG WORKSPACES_COMPONENT_IMG
ARG OS_IMG
FROM ${OS_IMG} as plugins_image

ARG RAINBOW_URL
ARG UNDOTREE_URL
ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY}"
    export https_proxy="${HTTPS_PROXY}"
    apk add --no-cache git
    git clone --depth=1 "${RAINBOW_URL}" /rainbow
    git clone --depth=1 "${UNDOTREE_URL}" /undotree
    unset http_proxy https_proxy
END_OF_RUN

FROM ${WORKSPACES_COMPONENT_IMG}

ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY}"
    export https_proxy="${HTTPS_PROXY}"
    apk add --no-cache gvim
    mkdir -p /root/.vim/plugin /root/.vim/autoload /root/.vim/syntax
    unset http_proxy https_proxy
END_OF_RUN

COPY --from=plugins_image /rainbow/plugin/ /root/.vim/plugin/
COPY --from=plugins_image /rainbow/autoload/ /root/.vim/autoload/
COPY --from=plugins_image /undotree/plugin/ /root/.vim/plugin/
COPY --from=plugins_image /undotree/autoload/ /root/.vim/autoload/
COPY --from=plugins_image /undotree/syntax/ /root/.vim/syntax/
COPY .vimrc /root/
COPY etc/ /etc/
