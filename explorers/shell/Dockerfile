ARG EXPLORER_COMPONENT_IMG
FROM ${EXPLORER_COMPONENT_IMG}

ARG WORKSPACES_PATH
ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY}"
    export https_proxy="${HTTPS_PROXY}"
    apk add --no-cache shellcheck bats
    mkdir -p "${WORKSPACES_PATH}"
    unset http_proxy https_proxy
END_OF_RUN

WORKDIR ${WORKSPACES_PATH}
