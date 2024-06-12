ARG ENTRYPOINT_LAYER_IMG
FROM ${ENTRYPOINT_LAYER_IMG}

ARG CHECK_ENTRYPOINT_PATH
ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY:-}"
    export https_proxy="${HTTPS_PROXY:-}"

    # See:
    # * https://wiki.alpinelinux.org/wiki/Intel_Video
    # * https://wiki.alpinelinux.org/wiki/Radeon_Video
    # * https://wiki.alpinelinux.org/wiki/NVIDIA
    pkg='mesa-dri-gallium mesa-va-gallium intel-media-driver libva-intel-driver linux-firmware-i915'
    apk add --no-cache ${pkg}
    _apk="$(command -v apk)"
    cat << TEMPLATING >> "${CHECK_ENTRYPOINT_PATH}"
#! /bin/sh

main ()
{
  set -eux

  # check packages are available
  for _pkg in ${pkg}
  do
    ${_apk} info --installed "\${_pkg}"
  done
}

main
TEMPLATING
    chmod 0700 "${CHECK_ENTRYPOINT_PATH}"
    unset http_proxy https_proxy
END_OF_RUN

ENV DISPLAY :0
