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
  docker compose --file "${1}/compose.yaml" stop --timeout 0 || :
  docker compose --file "${1}/compose.yaml" rm --force || :
  source_env_without_docker_host "${1}" \
    'docker volume rm $(docker volume list --filter "name=${DELETE_ME_SFX}" --format "{{ .Name }}")' || :
  rm -rf "${1}"
}

main ()
{
  set -eu

  local branch runner bot
  bot='bot'
  readonly bot

  while [ "${#}" != '0' ]
  do
    case "${1}" in
    ( '--runner-is-a-bot' ) runner="${bot}"; shift 1 ;;
    ( '--branch' ) branch="${2}"; shift 2 ;;
    ( * ) printf 'Unknown flag: "%s"\n' "${1}" >&2; return 1 ;;
    esac
  done

  branch="${branch:-trunk}"
  runner="${runner:-someone}"
  readonly branch runner

  if ! command -v docker > /dev/null; then wget -q -O- https://get.docker.com | sudo sh; fi

  local dist
  dist="$(. /etc/os-release && printf '%s\n' "${ID}")"
  readonly dist

  case "${dist}" in
  ( 'ubuntu'|'debian' ) sudo apt-get update -y; sudo apt-get upgrade -y ;;
  ( * ) printf 'Can not update Docker packages: unknown OS: %s\n' "${dist}" >&2; return 1 ;;
  esac

  local tmp dir_tmp base_tmp repo repo_url
  tmp="$(mktemp --directory)"
  dir_tmp="$(dirname "${tmp}")"
  base_tmp="$(basename "${tmp}")"
  repo='tiawl/MyWhaleFleet'
  repo_url="https://github.com/${repo}.git"
  readonly tmp dir_tmp base_tmp repo repo_url

  git clone --depth 1 --branch "${branch}" ${repo_url} "${tmp}" || \
  docker run --rm --volume "${HOME}:/root" --volume "${dir_tmp}:/git" 'alpine/git:user' \
    clone --depth 1 --branch "${branch}" "${repo_url}" "${base_tmp}"

  local daemon_json
  daemon_json='/etc/docker/daemon.json'
  readonly daemon_json

  if [ ! -e "${daemon_json}" ] || ! diff "${daemon_json}" "${tmp}/host/${daemon_json}" > /dev/null
  then
    sudo cp -f "${tmp}/host/${daemon_json}" "${daemon_json}"
    if command -v systemctl > /dev/null
    then
      sudo systemctl restart docker
    elif command -v service > /dev/null
    then
      sudo service docker restart
    else
      printf 'Can not restart Dockerd: unknown service manager\n' >&2
      return 1
    fi
  fi

  API_TAG="$(docker version --format '{{ .Server.APIVersion }}')"
  export API_TAG

  trap "trap_me '${tmp}'" EXIT

  for template in $(find "${tmp}" -type f -name compose.yaml.in)
  do
    source_env "${tmp}" "printf '%s\n' \"$(cat "${template}")\"" > "${template%.*}"
  done

  docker network prune --force
  docker compose --file "${tmp}/components/compose.yaml" build
  docker compose --file "${tmp}/compose.yaml" build
  docker compose --file "${tmp}/compose.yaml" create --no-recreate
  docker compose --file "${tmp}/compose.yaml" start
  printf 'Sleeping ...\n'
  sleep 3

  local services
  services="$(docker compose --file "${tmp}/compose.yaml" ps \
    --filter 'status=exited' --filter 'status=restarting' \
    --filter 'status=removing' --filter 'status=paused' \
    --filter 'status=dead' --filter 'status=created' --format json)"
  readonly services
  if [ -n "${services}" ]
  then
    printf 'A service did not starts correctly: %s\n' "${services}" >&2
    return 1
  fi

  docker volume prune --all --force
  docker image prune --force > /dev/null

  source_env_without_docker_host "${tmp}" \
    'docker logs "${PROXY_SERVICE}" 2> /dev/null | sed -n "/^-----\+$/,/^-----\+$/p"'

  if [ "${runner}" != "${bot}" ]
  then
    source_env_without_docker_host "${tmp}" \
      "docker compose --file '${tmp}/compose.yaml' attach \"\${JUMPER_SERVICE}\""
  fi

  wget -q -O "$(cd -- "$(dirname -- "${0}")" &> /dev/null && pwd)/$(basename -- "${0}")" \
    "https://raw.githubusercontent.com/${repo}/${branch}/wget_me.sh"
}

main ${@}
