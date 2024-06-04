ARG SPECTRWM_LAYER_IMG

FROM ${SPECTRWM_LAYER_IMG}

ARG ENTRYPOINTD_PATH
ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY:-}"
    export https_proxy="${HTTPS_PROXY:-}"
    _spectrwm="$(command -v spectrwm)"
    wm_entrypoint="${ENTRYPOINTD_PATH}/99wm.sh"
    cat << TEMPLATING > "${wm_entrypoint}"
#! /bin/sh

main ()
{
  set -eux
  exec ${_spectrwm}
}

main
TEMPLATING
    chmod 0700 "${wm_entrypoint}"
    unset http_proxy https_proxy
END_OF_RUN

ENV DISPLAY :0
