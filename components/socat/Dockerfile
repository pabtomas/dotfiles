ARG ENTRYPOINT_COMPONENT_IMG
FROM ${ENTRYPOINT_COMPONENT_IMG}

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY:-}"
    export https_proxy="${HTTPS_PROXY:-}"
    apk add --no-cache socat
    unset http_proxy https_proxy
END_OF_RUN
