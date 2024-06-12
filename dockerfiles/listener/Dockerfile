ARG ENTRYPOINT_LAYER_IMG

FROM ${ENTRYPOINT_LAYER_IMG}

ARG CHECK_ENTRYPOINT_PATH
ARG COMPLETION_PATH
ARG DATA_PATH
ARG _DOCKER_SOCKET_PATH
ARG ENTRYPOINTD_PATH
ARG HTTP_DOCKER_TARGET
ARG NET
ARG OPT_SCRIPTS_PATH
ARG VAR_LOG_PATH
ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY:-}"
    export https_proxy="${HTTPS_PROXY:-}"
    apk add --no-cache jq
    mkdir -p "${DATA_PATH}"
    _jq="$(command -v jq)"
    _wget="$(command -v wget)"
    listen_script="${OPT_SCRIPTS_PATH}/listen.sh"
    cat << TEMPLATING > "${listen_script}"
#! /bin/sh

main ()
{
  set -x

  while :;
  do
    ${_wget} -q -O- '${HTTP_DOCKER_TARGET}/events' | \
      while read -r event
      do
        event="\$(printf '%s\n' "\${event}" | ${_jq} -c '. | select(.Type=="network" and (.Action=="connect" or .Action=="disconnect") and .Actor.Attributes.name=="jump-area")')"
        if [ -n "\${event}" ]
        then
          id="\$(${_wget} -q -O- '${HTTP_DOCKER_TARGET}/networks' | ${_jq} -r '.[] | select(.Name=="${NET}") | .Id')"
          ${_wget} -q -O- "${HTTP_DOCKER_TARGET}/networks/\${id}" | ${_jq} -r '.Containers | to_entries[] | .value.Name' > '${COMPLETION_PATH}'
        fi
      done
  done
}

main > ${VAR_LOG_PATH}/listen.log 2>&1
TEMPLATING
    listen_entrypoint="${ENTRYPOINTD_PATH}/99listen.sh"
    cat << TEMPLATING > "${listen_entrypoint}"
#! /bin/sh

main ()
{
  exec ${listen_script}
}

main
TEMPLATING
    cat << TEMPLATING >> "${CHECK_ENTRYPOINT_PATH}"
#! /bin/sh

main ()
{
  set -eux

  # check jq availability
  ${_jq} --version

  # check docker socket is reachable
  ${_wget} -q -O- '${HTTP_DOCKER_TARGET}/version'
}

main
TEMPLATING
    chmod 0700 "${listen_script}" "${listen_entrypoint}" "${CHECK_ENTRYPOINT_PATH}"
    unset http_proxy https_proxy
END_OF_RUN
