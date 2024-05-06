ARG OS
FROM ${OS}

ARG ZIG_TAG

ARG USE_PROXY

RUN <<END_OF_RUN
    set -eux
    if [ -n "${USE_PROXY}" ]; then export http_proxy="${USE_PROXY}" https_proxy="${USE_PROXY}"; fi
    apk add --no-cache curl
    XZ="zig-linux-$(arch)-${ZIG_TAG}.tar.xz"
    TMP_XZ="/tmp/${XZ}"; TMP_ZIG='/tmp/zig'
    curl --output "${TMP_XZ}" "https://ziglang.org/builds/${XZ}"
    mkdir -p "${TMP_ZIG}"
    tar -xvf "${TMP_XZ}" --strip-component 1 -C "${TMP_ZIG}"
    mv -t /usr/local/bin/ "${TMP_ZIG}/lib/" "${TMP_ZIG}/zig"
    rm -rf "${TMP_XZ}" "${TMP_ZIG}"
    if [ -n "${USE_PROXY}" ]; then unset http_proxy https_proxy; fi
END_OF_RUN

ENTRYPOINT ["zig"]
CMD ["version"]
