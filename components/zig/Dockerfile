ARG GIT_COMPONENT_IMG
FROM ${GIT_COMPONENT_IMG}

ARG BASH_COMPLETION_PATH
ARG ZIG_BUILDS_URL
ARG ZIG_COMPLETION_URL
ARG ZIG_COMPONENT_TAG

ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY:-}"
    export https_proxy="${HTTPS_PROXY:-}"
    xz="zig-linux-$(arch)-${ZIG_COMPONENT_TAG}.tar.xz"
    tmp_xz="/tmp/${xz}"
    tmp_zig='/tmp/zig'
    wget -O "${tmp_xz}" "${ZIG_BUILDS_URL}/${xz}"
    mkdir -p "${tmp_zig}"
    tar -xvf "${tmp_xz}" --strip-component 1 -C "${tmp_zig}"
    mv -t /usr/local/bin/ "${tmp_zig}/lib/" "${tmp_zig}/zig"
    rm -rf "${tmp_xz}" "${tmp_zig}"
    wget -O "${BASH_COMPLETION_PATH}/99zig.sh" "${ZIG_COMPLETION_URL}"
    unset http_proxy https_proxy
END_OF_RUN
