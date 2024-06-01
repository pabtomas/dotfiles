ARG BASE_IMG
FROM ${BASE_IMG}

ARG CHECK_ENTRYPOINT_PATH
ARG CHECK_ENTRYPOINTD_PATH
ARG _COMPOSE_ROUTES
ARG _COMPOSE_VOLUMES
ARG ENTRYPOINT_PATH
ARG ENTRYPOINTD_PATH
ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY:-}"
    export https_proxy="${HTTPS_PROXY:-}"
    opt_compose='/opt/compose'
    mkdir -p "${opt_compose}/volumes" "${opt_compose}/routes"
    set -- ${_COMPOSE_VOLUMES}
    while [ "${#}" != '0' ]
    do
      printf '%s\n' "${2}" >> "${opt_compose}/volumes/${1}"
      shift 2
    done
    set -- ${_COMPOSE_ROUTES}
    while [ "${#}" != '0' ]
    do
      printf '%s\n' "${2%/*}" >> "${opt_compose}/routes/${1}"
      shift 2
    done
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
    check_compose="${CHECK_ENTRYPOINTD_PATH}/99compose.sh"
    _cat="$(command -v cat)"
    _grep="$(command -v grep)"
    _hostname="$(command -v hostname)"
    _realpath="$(command -v realpath)"
    _sort="$(command -v sort)"
    _uniq="$(command -v uniq)"
    cat << TEMPLATING > "${check_compose}"
#! /bin/sh

main ()
{
  # check volumes are mounted
  for target in \$(${_cat} ${opt_compose}/volumes/\$(${_hostname}))
  do
    ${_grep} " \$(${_realpath} "\${target}") " /etc/mtab
  done

  # check routes are available
  [ -z "\$(for ip in \$(${_hostname} -i) \$(${_cat} ${opt_compose}/routes/\$(${_hostname}))
           do
             ip="\${ip%.*}"
             ip="\${ip##*.}"
             printf '%s\n' "\${ip}"
           done | ${_sort} | ${_uniq} -u)" ]
}

main
TEMPLATING
    chmod 0700 "${ENTRYPOINT_PATH}" "${CHECK_ENTRYPOINT_PATH}" "${check_compose}"
    unset http_proxy https_proxy
END_OF_RUN

ENV ENTRYPOINT_PATH ${ENTRYPOINT_PATH}
ENTRYPOINT ${ENTRYPOINT_PATH}
