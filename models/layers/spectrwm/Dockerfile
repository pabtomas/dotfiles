ARG ENTRYPOINT_LAYER_IMG
FROM ${ENTRYPOINT_LAYER_IMG}

ARG BIN_PATH
ARG CHECK_ENTRYPOINT_PATH

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY:-}"
    export https_proxy="${HTTPS_PROXY:-}"
    pkg='spectrwm xterm'
    apk add --no-cache ${pkg}
    _apk="$(command -v apk)"
    _spectrwm="$(command -v spectrwm)"
    cat << TEMPLATING >> "${CHECK_ENTRYPOINT_PATH}"
#! /bin/sh

main ()
{
  set -eux

  # check spectrwm availability
  ${_spectrwm} -v || :

  # check packages are available
  for _pkg in ${pkg}
  do
    ${_apk} info --installed "\${_pkg}"
  done
}

main
TEMPLATING
    xterm="${BIN_PATH}/xterm"
    xlock="${BIN_PATH}/xlock"
    : > "${xterm}"
    : > "${xlock}"
    chmod 0700 "${CHECK_ENTRYPOINT_PATH}" "${xterm}" "${xlock}"
    unset http_proxy https_proxy
END_OF_RUN
