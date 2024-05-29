ARG ENTRYPOINT_COMPONENT_IMG
FROM ${ENTRYPOINT_COMPONENT_IMG}

ARG CHECK_ENTRYPOINT_PATH

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY:-}"
    export https_proxy="${HTTPS_PROXY:-}"
    apk add --no-cache socat
    _socat="$(command -v socat)"
    cat << TEMPLATING >> "${CHECK_ENTRYPOINT_PATH}"
#! /bin/sh

main ()
{
  set -eux

  # check socat availability
  ${_socat} -V
}

main
TEMPLATING
    chmod 0700 "${CHECK_ENTRYPOINT_PATH}"
    unset http_proxy https_proxy
END_OF_RUN
