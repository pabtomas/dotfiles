ARG ENTRYPOINT_COMPONENT_IMG

FROM ${ENTRYPOINT_COMPONENT_IMG}

ARG APK_PATHS
ARG COMPLETION_PATH
ARG DATA_PATH
ARG ENTRYPOINTD_PATH
ARG HTTP_DOCKER_HOST
ARG NET
ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY:-}"
    export https_proxy="${HTTPS_PROXY:-}"
    apk add --no-cache jq
    rm -rf ${APK_PATHS}
    mkdir -p "${DATA_PATH}"
    _jq="$(command -v jq)"
    _wget="$(command -v wget)"
    _xargs="$(command -v xargs)"
    listen_entrypoint="${ENTRYPOINTD_PATH}/99listen.sh"
    cat << TEMPLATING > "${listen_entrypoint}"
#! /bin/sh

main ()
{
  set -eux

  ${_wget} -q -O- '${HTTP_DOCKER_HOST}/events' | \
    while read -r event
    do
      event="\$(printf '%s\n' "\${event}" | ${_jq} -c '. | select(.Type=="network" and (.Action=="connect" or .Action=="disconnect") and .Actor.Attributes.name=="jump-area")')"
      if [ -n "\${event}" ]
      then
        id="\$(${_wget} -q -O- '${HTTP_DOCKER_HOST}/networks' | ${_jq} -r '.[] | select(.Name=="${NET}") | .Id')"
        ${_wget} -q -O- "${HTTP_DOCKER_HOST}/networks/\${id}" | ${_jq} -r '.Containers | to_entries[] | .value.Name' > '${COMPLETION_PATH}'
      fi
    done
}

main
TEMPLATING
    chmod 0700 "${listen_entrypoint}"
    unset http_proxy https_proxy
END_OF_RUN
