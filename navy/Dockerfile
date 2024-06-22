FROM docker:cli AS docker_image
FROM alpine:3.20

ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    http_proxy="${HTTP_PROXY:-}"
    https_proxy="${HTTPS_PROXY:-}"
    export http_proxy https_proxy
    # TODO: install zig
    apk add --no-cache dash coreutils bc moreutils curl yq gomplate
    apk add --no-cache --repository https://dl-cdn.alpinelinux.org/alpine/edge/testing lolcat
    apk add --no-cache --virtual __install_ansi2txt cmake git build-base gcc
    git clone https://github.com/kilobyte/colorized-logs.git
    mkdir -p /build
    cmake -B /build /colorized-logs
    make -C /build
    make -C /build install
    rm -rf /build /colorized-logs
    apk del __install_ansi2txt
    mkdir -p /navy
    unset http_proxy https_proxy
END_OF_RUN

COPY ./navy /usr/local/bin/
COPY --from=docker_img /usr/local/bin/docker /usr/local/bin/

WORKDIR /navy

ENTRYPOINT ["/usr/local/bin/navy"]
