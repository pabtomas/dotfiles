ARG OS
FROM ${OS}

ARG ZIG_TAG

ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    if [ -n "${HTTP_PROXY}" ]; then export http_proxy="${HTTP_PROXY}"; fi
    if [ -n "${HTTPS_PROXY}" ]; then export https_proxy="${HTTPS_PROXY}"; fi
    apk add --no-cache curl
    XZ="zig-linux-$(arch)-${ZIG_TAG}.tar.xz"
    TMP_XZ="/tmp/${XZ}"; TMP_ZIG='/tmp/zig'
    curl --output "${TMP_XZ}" "https://ziglang.org/builds/${XZ}"
    mkdir -p "${TMP_ZIG}"
    tar -xvf "${TMP_XZ}" --strip-component 1 -C "${TMP_ZIG}"
    mv -t /usr/local/bin/ "${TMP_ZIG}/lib/" "${TMP_ZIG}/zig"
    rm -rf "${TMP_XZ}" "${TMP_ZIG}"
    if [ -n "${HTTP_PROXY}" ]; then unset http_proxy; fi
    if [ -n "${HTTPS_PROXY}" ]; then unset https_proxy; fi
END_OF_RUN

ENTRYPOINT ["zig"]
CMD ["version"]
