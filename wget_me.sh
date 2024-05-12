#!/bin/sh

source_env ()
(
  set -a
  . "${1}/env.sh"
  eval "${2}"
)

source_env_without_docker_host ()
(
  . "${1}/env.sh"
  unset DOCKER_HOST
  eval "${2}"
)

trap_me ()
{
  docker compose down --timeout 0 || :
  source_env_without_docker_host "${1}" \
    'docker volume rm $(docker volume list --filter "name=${DELETE_ME_SFX}" --format "{{ .Name }}")' || :
  rm -rf "${1}" "${2}"
}

main ()
{
  set -eu

  local tmp dir_tmp base_tmp
  tmp="$(mktemp --directory)"
  dir_tmp="$(dirname tmp)"
  base_tmp="$(basename tmp)"
  readonly tmp dir_tmp base_tmp

  docker run --interactive --tty --name 'git' --rm --volume "${dir_tmp}:/git" 'alpine/git:user' \
    clone --depth 1 https://github.com/tiawl/my-whale-fleet.git "${base_tmp}"
  docker rm --force 'git'

  for template in $(find "${tmp}" -type f -name compose.yaml.in)
  do
    source_env "${tmp}" "printf '%s\n' \"$(cat "${template}")\"" > "${template%.*}"
  done

  TRASH_PATH="$(mktemp --directory)"
  export TRASH_PATH

  trap "trap_me '${tmp}' '${TRASH_PATH}'" EXIT

  docker network prune --force
  docker compose --file "${tmp}/components/compose.yaml" build
  docker compose --file "${tmp}/compose.yaml" build
  docker compose --file "${tmp}/compose.yaml" create --no-recreate
  docker compose --file "${tmp}/compose.yaml" start
  docker volume prune --all --force
  source_env_without_docker_host "${tmp}" \
    'docker logs "${PROXY_ID}" 2> /dev/null | sed -n "/^-----\+$/,/^-----\+$/p"'
  docker image prune --all --force > /dev/null
  if [ "${1:-}" != '--no-attach' ]; then docker attach jumper; fi
}

main ${@}
