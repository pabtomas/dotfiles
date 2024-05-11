ARG WORKSPACES_COMPONENT_IMG
FROM ${WORKSPACES_COMPONENT_IMG}

ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY}"
    export https_proxy="${HTTPS_PROXY}"
    apk add --no-cache git tig ripgrep
    unset http_proxy https_proxy
END_OF_RUN

COPY etc/profile.d/* /etc/profile.d/
