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
  docker compose --file "${1}/compose.yaml" down --timeout 0 || :
  source_env_without_docker_host "${1}" \
    'docker volume rm $(docker volume list --filter "name=${DELETE_ME_SFX}" --format "{{ .Name }}")' || :
  rm -rf "${1}" "${2}"
}

main ()
{
  set -eu

  if ! command -v docker; then wget -q -O- https://get.docker.com | sudo sh; fi

  local dist
  dist="$(. /etc/os-release && printf '%s\n' "${ID}")"
  readonly dist

  case "${dist}" in
  ( 'ubuntu'|'debian' ) sudo apt-get update; sudo apt-get upgrade ;;
  ( * ) printf 'Can not update Docker packages: unknown OS: %s\n' "${dist}" >&2; return 1 ;;
  esac

  local tmp dir_tmp base_tmp
  tmp="$(mktemp --directory)"
  dir_tmp="$(dirname "${tmp}")"
  base_tmp="$(basename "${tmp}")"
  readonly tmp dir_tmp base_tmp

  git clone --depth 1 --branch "${2:-trunk}" https://github.com/tiawl/my-whale-fleet.git "${tmp}" || \
  docker run --rm --volume "${HOME}:/root" --volume "${dir_tmp}:/git" 'alpine/git:user' \
    clone --depth 1 --branch "${2:-trunk}" https://github.com/tiawl/my-whale-fleet.git "${base_tmp}"

  if [ ! -e /etc/docker/daemon.json ] || ! diff /etc/docker/daemon.json "${tmp}/host/etc/docker/daemon.json" > /dev/null
  then
    cp -f "${tmp}/host/etc/docker/daemon.json" /etc/docker/daemon.json
    if command -v systemctl
    then
      sudo systemctl restart docker
    else if command -v service
      sudo service docker restart
    else
      printf 'Can not restart Dockerd: unknown service manager\n' >&2
      return 1
    fi
  fi

  TRASH_PATH="$(mktemp --directory)"
  API_TAG="$(docker version --format '{{ .Server.APIVersion }}')"
  export TRASH_PATH API_TAG

  trap "trap_me '${tmp}' '${TRASH_PATH}'" EXIT

  for template in $(find "${tmp}" -type f -name compose.yaml.in)
  do
    source_env "${tmp}" "printf '%s\n' \"$(cat "${template}")\"" > "${template%.*}"
  done

  docker network prune --force
  docker compose --file "${tmp}/components/compose.yaml" build
  docker compose --file "${tmp}/compose.yaml" up --no-recreate --abort-on-container-failure
  docker volume prune --all --force
  source_env_without_docker_host "${tmp}" \
    'docker logs "${PROXY_ID}" 2> /dev/null | sed -n "/^-----\+$/,/^-----\+$/p"'
  docker image prune --force > /dev/null
  if [ "${1:-}" != '--no-attach' ]; then docker compose --file "${tmp}/compose.yaml" attach jumper; fi

  wget -q -O "$(cd -- "$(dirname -- "${0}")" &> /dev/null && pwd)/$(basename -- "${0}")" \
    https://raw.githubusercontent.com/tiawl/MyWhaleFleet/trunk/wget_me.sh
}

main ${@}
