ARG OS_LOCAL_IMG
FROM ${OS_LOCAL_IMG}

ARG CHECK_ENTRYPOINT_PATH
ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY:-}"
    export https_proxy="${HTTPS_PROXY:-}"
    apk add --no-cache --virtual __install_fonts git
    git clone --depth 1 "${FIGLET_FONTS_URL}" /usr/share/figlet/fonts/
    apk del __install_fonts
    apk add --no-cache figlet lolcat
    _figlet="$(command -v figlet)"
    _lolcat="$(command -v lolcat)"
    cat << TEMPLATING >> "${CHECK_ENTRYPOINT_PATH}"
#! /bin/sh

main ()
{
  set -eux

  # check figlet & lolcat availability
  ${_figlet} -v
  ${_locat} --version
}

main
TEMPLATING
    chmod 0700 "${CHECK_ENTRYPOINT_PATH}"
    unset http_proxy https_proxy
END_OF_RUN
