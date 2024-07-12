FROM alpine:3.20

COPY ./utils /tmp/

ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -euxo pipefail
    http_proxy="${HTTP_PROXY:-}"
    https_proxy="${HTTPS_PROXY:-}"
    export http_proxy https_proxy

    apk add --no-cache coreutils findutils moreutils curl yq gomplate ripgrep

    apk add --no-cache --virtual __install_ansi2txt cmake git build-base gcc
    git clone https://github.com/kilobyte/colorized-logs.git
    mkdir -p /build
    cmake -B /build /colorized-logs
    make -C /build
    make -C /build install
    rm -rf /build /colorized-logs
    apk del __install_ansi2txt

    xz="zig-linux-$(arch)-0.13.0.tar.xz"
    tmp_xz="/tmp/${xz}"
    tmp_zig='/tmp/zig'
    wget -O "${tmp_xz}" "https://ziglang.org/builds/${xz}"
    mkdir -p "${tmp_zig}"
    tar -xvf "${tmp_xz}" --strip-component 1 -C "${tmp_zig}"
    mv -t /usr/local/bin "${tmp_zig}/lib/" "${tmp_zig}/zig"

    for util in /tmp/utils/*
    do
      cd "${util}"
      zig build -p /usr/local
    done
    rm -rf "${tmp_xz}" "${tmp_zig}" /usr/local/bin/lib /usr/local/bin/zig /tmp/utils

    mkdir -p /exodia
    unset http_proxy https_proxy
END_OF_RUN

COPY ./exodia /usr/local/bin/

WORKDIR /exodia

ENTRYPOINT ["/usr/local/bin/exodia"]
