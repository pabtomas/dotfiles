ARG OS_IMG
FROM ${OS_IMG}

ARG ZIG_TAG

ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    if [ -n "${HTTP_PROXY}" ]; then export http_proxy="${HTTP_PROXY}"; fi
    if [ -n "${HTTPS_PROXY}" ]; then export https_proxy="${HTTPS_PROXY}"; fi
    apk add --no-cache curl
    xz="zig-linux-$(arch)-${ZIG_TAG}.tar.xz"
    tmp_xz="/tmp/${xz}"
    tmp_zig='/tmp/zig'
    curl --output "${tmp_xz}" "https://ziglang.org/builds/${xz}"
    mkdir -p "${tmp_zig}"
    tar -xvf "${tmp_xz}" --strip-component 1 -C "${tmp_zig}"
    mv -t /usr/local/bin/ "${tmp_zig}/lib/" "${tmp_zig}/zig"
    rm -rf "${tmp_xz}" "${tmp_zig}"
    if [ -n "${HTTP_PROXY}" ]; then unset http_proxy; fi
    if [ -n "${HTTPS_PROXY}" ]; then unset https_proxy; fi
END_OF_RUN

ENTRYPOINT ["zig"]
CMD ["version"]
