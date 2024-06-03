ARG WORKSPACES_LAYER_IMG
FROM ${WORKSPACES_LAYER_IMG}

ARG CHECK_ENTRYPOINT_PATH
ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY:-}"
    export https_proxy="${HTTPS_PROXY:-}"
    pkg='findutils jq yq'
    apk add --no-cache ${pkg}
    _apk="$(command -v apk)"
    _jq="$(command -v jq)"
    _yq="$(command -v yq)"
    cat << TEMPLATING > "${CHECK_ENTRYPOINT_PATH}"
#! /bin/sh

main ()
{
  set -eux

  # check jq & yq are available
  ${_jq} --version
  ${_yq} --version

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
