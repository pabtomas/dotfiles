#! /usr/bin/env bash

main ()
{
  set -eu

  if [[ "${#}" != '1' ]]; then printf '%s needs 1 parameter\n' "${0}" >&2; return 1; fi

  local target runners
  target="${1}"
  readonly target

  CDPATH='' cd -- "$(dirname -- "${0}")" > /dev/null 2>&1
  runners="$(pwd)"
  readonly runners

  (
    set -- "${runners}/.."
    API_TAG="$(docker version --format '{{ .Server.APIVersion }}')"
    export API_TAG
    source "${1}/env.sh"
    eval "printf '%s\\n%s\\n' \"$(cat "${runners}/../anchors.yaml.in")\" \"$(cat "${runners}/${target}/compose.yaml.in")\"" > "${runners}/${target}/compose.yaml"
  )

  docker compose --file "${runners}/${target}/compose.yaml" build
  docker compose --file "${runners}/${target}/compose.yaml" create
  docker compose --file "${runners}/${target}/compose.yaml" start
}

main "${@}"
