ARG ENTRYPOINT_LAYER_IMG
FROM ${ENTRYPOINT_LAYER_IMG}

ARG CHECK_ENTRYPOINT_PATH
ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY:-}"
    export https_proxy="${HTTPS_PROXY:-}"
    apk add --no-cache --virtual __install_linguist ruby-dev build-base cmake
    apk add --no-cache ruby cmake icu-dev zlib-dev openssl-dev libcurl cloc
    gem install github-linguist
    apk del __install_linguist
    _linguist="$(command -v github-linguist)"
    cat << TEMPLATING >> "${CHECK_ENTRYPOINT_PATH}"
#! /bin/sh

main ()
{
  set -eux

  # check linguist availability
  ${_linguist} --version
}

main
TEMPLATING
    chmod 0700 "${CHECK_ENTRYPOINT_PATH}"
    unset http_proxy https_proxy
END_OF_RUN

CMD ["github-linguist", "--version"]
