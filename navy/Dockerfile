FROM alpine:3.20

ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    http_proxy="${HTTP_PROXY:-}"
    https_proxy="${HTTPS_PROXY:-}"
    export http_proxy https_proxy
    apk add --no-cache dash yq curl gomplate gum
    unset http_proxy https_proxy
END_OF_RUN

COPY ./navy /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/navy"]
