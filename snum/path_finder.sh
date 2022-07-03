#!/bin/sh

set -eu

fpop () {
  shift "$(( ${1} + 1 ))"
  printf '%s\n' "${@}"
}

cd tree/
set -- "" *
while [ ${#} -gt 1 ]
do
  if [ -d "${2}" ]
  then
    set -f
    set +f -- "${1}${1:+ }${2}$(
      [ -f "${2}"/parent ] && read -r < "${2}"/parent && printf ':%s' "${REPLY}"
    )$(
      [ -f "${2}"/children ] && read -r < "${2}"/children && set -f \
        && printf ':%s' ${REPLY} && set +f
    )" $(fpop 2 "${@}")
  else
    set -f
    set +f -- "${1}" $(fpop 2 "${@}")
  fi
done

set -- ${@}
printf '%s\n' "${*}"
