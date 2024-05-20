#! /usr/bin/env bash

main ()
{
  set -eu

  if [[ "${#}" != '1' ]]; then printf '%s needs 1 parameter\n' "${0}" >&2; return 1; fi

  local docker_host id runners
  docker_host="${DOCKER_HOST}"
  id="${1}"
  readonly docker_host id

  CDPATH='' cd -- "$(dirname -- "${0}")" > /dev/null 2>&1
  runners="$(pwd)"
  readonly runners

  (
    set -- "${runners}/.."
    source "${1}/env.sh"
    eval "printf '%s\\n' \"$(cat "${runners}/${id}/compose.yaml.in")\"" > "${runners}/${id}/compose.yaml"
  )

  docker compose --file "${runners}/${id}/compose.yaml" build
  docker compose --file "${runners}/${id}/compose.yaml" create
  docker compose --file "${runners}/${id}/compose.yaml" start
}

main "${@}"
