ARG ENTRYPOINT_LAYER_IMG
FROM ${ENTRYPOINT_LAYER_IMG}

ARG CHECK_ENTRYPOINT_PATH

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY:-}"
    export https_proxy="${HTTPS_PROXY:-}"
    apk add --no-cache spectrwm
    _spectrwm="$(command -v spectrwm)"
    cat << TEMPLATING >> "${CHECK_ENTRYPOINT_PATH}"
#! /bin/sh

main ()
{
  set -eux

  # check spectrwm availability
  ${_spectrwm} --version
}

main
TEMPLATING
    chmod 0700 "${CHECK_ENTRYPOINT_PATH}"
    unset http_proxy https_proxy
END_OF_RUN
