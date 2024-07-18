FROM alpine:3.20

COPY ./utils /tmp/

ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -euxo pipefail
    http_proxy="${HTTP_PROXY:-}"
    https_proxy="${HTTPS_PROXY:-}"
    export http_proxy https_proxy

    apk add --no-cache git make findutils musl-dev go
    GOROOT='/usr/lib/go'
    #GOPATH='/go'
    #PATH="/go/bin:${PATH}"
    #mkdir -p "${GOPATH}/src" "${GOPATH}/bin"

    mkdir -p /exodia
    unset http_proxy https_proxy
END_OF_RUN

COPY ./exodia /usr/local/bin/

WORKDIR /exodia

ENTRYPOINT ["/usr/local/bin/exodia"]
