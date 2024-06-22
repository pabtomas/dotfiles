ARG GIT_LAYER_IMG
FROM ${GIT_LAYER_IMG}

ARG BASH_COMPLETION_PATH
ARG BIN_PATH
ARG CHECK_ENTRYPOINT_PATH
ARG ZIG_BUILDS_URL
ARG ZIG_COMPLETION_URL
ARG ZIG_TAG

ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    http_proxy="${HTTP_PROXY:-}"
    https_proxy="${HTTPS_PROXY:-}"
    export http_proxy https_proxy
    xz="zig-linux-$(arch)-${ZIG_TAG}.tar.xz"
    tmp_xz="/tmp/${xz}"
    tmp_zig='/tmp/zig'
    wget -O "${tmp_xz}" "${ZIG_BUILDS_URL}/${xz}"
    mkdir -p "${tmp_zig}"
    tar -xvf "${tmp_xz}" --strip-component 1 -C "${tmp_zig}"
    mv -t "${BIN_PATH}" "${tmp_zig}/lib/" "${tmp_zig}/zig"
    rm -rf "${tmp_xz}" "${tmp_zig}"
    wget -O "${BASH_COMPLETION_PATH}/99zig.sh" "${ZIG_COMPLETION_URL}"
    _zig="$(command -v zig)"
    cat << TEMPLATING >> "${CHECK_ENTRYPOINT_PATH}"
#! /bin/sh

main ()
{
  set -eux

  # check zig availability
  ${_zig} version
}

main
TEMPLATING
    chmod 0700 "${CHECK_ENTRYPOINT_PATH}"
    unset http_proxy https_proxy
END_OF_RUN
