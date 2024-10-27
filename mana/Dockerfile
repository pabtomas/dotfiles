FROM alpine:3.20

COPY ./utils /tmp/

ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -euxo pipefail
    http_proxy="${HTTP_PROXY:-}"
    https_proxy="${HTTPS_PROXY:-}"
    export http_proxy https_proxy

    xz="zig-linux-$(arch)-0.13.0.tar.xz"
    tmp_xz="/tmp/${xz}"
    tmp_zig='/tmp/zig'
    wget -O "${tmp_xz}" "https://ziglang.org/builds/${xz}"
    mkdir -p "${tmp_zig}"
    tar -xvf "${tmp_xz}" --strip-component 1 -C "${tmp_zig}"
    mv -t /usr/local/bin "${tmp_zig}/lib/" "${tmp_zig}/zig"

    mkdir -p /mana
    unset http_proxy https_proxy
END_OF_RUN

COPY ./mana /usr/local/bin/

WORKDIR /mana

ENTRYPOINT ["/usr/local/bin/mana"]
