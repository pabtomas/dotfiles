ARG BASE_IMG
FROM ${BASE_IMG}

ARG CHECK_ENTRYPOINT_PATH
ARG CHECK_ENTRYPOINTD_PATH
ARG _COMPOSE_FILE
ARG ENTRYPOINT_PATH
ARG ENTRYPOINTD_PATH
ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY:-}"
    export https_proxy="${HTTPS_PROXY:-}"
    apk add --no-cache yq
    mkdir -p "${ENTRYPOINTD_PATH}" "${CHECK_ENTRYPOINTD_PATH}"
    cat << TEMPLATING > "${ENTRYPOINT_PATH}"
#! /bin/sh

main ()
{
  set -eux
  if [ -d ${ENTRYPOINTD_PATH} ]
  then
    for file in ${ENTRYPOINTD_PATH}/*.sh
    do
      if [ -r "\${file}" ]
      then
        . "\${file}"
      fi
    done
    unset file
  fi
}

main
TEMPLATING
    cat << TEMPLATING > "${CHECK_ENTRYPOINT_PATH}"
#! /bin/sh

main ()
{
  set -eux
  if [ -d ${CHECK_ENTRYPOINTD_PATH} ]
  then
    for file in ${CHECK_ENTRYPOINTD_PATH}/*.sh
    do
      if [ -r "\${file}" ]
      then
        . "\${file}"
      fi
    done
    unset file
  fi
}

main
TEMPLATING
    check_volumes="${CHECK_ENTRYPOINTD_PATH}/99volumes.sh"
    _grep="$(command -v grep)"
    _hostname="$(command -v hostname)"
    _mount="$(command -v mount)"
    _realpath="$(command -v realpath)"
    _yq="$(command -v yq)"
    cat << TEMPLATING > "${check_volumes}"
#! /bin/sh

main ()
{
  # check yq is available
  ${_yq} --version

  ${_mount} >&2
  cat /etc/mtab

  # check volumes are mounted
  for target in \$(printf '%s\n' "${_COMPOSE_FILE}" | ${_yq} ".services.\$(${hostname}).volumes.[].target")
  do
    ${_mount} | ${_grep} " \$(${_realpath} "\${target}") "
  done
}

main
TEMPLATING
    chmod 0700 "${ENTRYPOINT_PATH}" "${CHECK_ENTRYPOINT_PATH}" "${check_volumes}"
    unset http_proxy https_proxy
END_OF_RUN

ENV ENTRYPOINT_PATH ${ENTRYPOINT_PATH}
ENTRYPOINT ${ENTRYPOINT_PATH}
