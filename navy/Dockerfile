FROM docker:cli AS docker_image
FROM alpine:3.20

ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    http_proxy="${HTTP_PROXY:-}"
    https_proxy="${HTTPS_PROXY:-}"
    export http_proxy https_proxy
    apk add --no-cache dash coreutils findutils moreutils curl yq gomplate
    apk add --no-cache --repository https://dl-cdn.alpinelinux.org/alpine/edge/testing lolcat
    mkdir -p /navy
    unset http_proxy https_proxy
END_OF_RUN

COPY ./navy /usr/local/bin/
COPY --from=docker_img /usr/local/bin/docker /usr/local/bin/

WORKDIR /navy

ENTRYPOINT ["/usr/local/bin/navy"]
