#! /bin/sh
{

main ()
(
  if [ -n "${DEBUG:-}" ]; then \command set -x; fi
  \command set -eu
  \command unalias -a
  \command unset -f command
  command unset -f unset
  unset -f set
  unset -f readonly

  old_ifs="${IFS}"
  readonly old_ifs

  IFS='
'
  for func in $(set)
  do
    func="${func#"${func%%[![:space:]]*}"}"
    func="${func%"${func##*[![:space:]]}"}"
    case "${func}" in
    ( *' ()' ) unset -f "${func%' ()'}" ;;
    ( * ) ;;
    esac
  done
  IFS="${old_ifs}"
  unset func

  harden ()
  {
    if [ -n "${DEBUG:-}" ]; then set -x; fi
    path="$(command -v "${1}")"
    if [ -e "${path}" ]
    then
      eval "${2:-"${1}"} () { ${3:+sudo} ${path} \"\${@}\"; }"
    else
      path="$(whence -p "${1}")"
      if [ -e "${path}" ]
      then
        eval "${2:-"${1}"} () { ${3:+sudo} ${path} \"\${@}\"; }"
      else
        printf 'This script needs "%s" but can not find it\n' "${1}" >&2
        return 1
      fi
    fi
    unset path
  }

  source_env_without_docker_host ()
  (
    if [ -n "${DEBUG:-}" ]; then set -x; fi
    . "${1}/env.sh"
    unset DOCKER_HOST
    eval "${2}"
  )

  # shellcheck disable=2317
  # SC2317: Command appears to be unreachable => reached indirectly into the trap statement
  update_me ()
  (
    if [ -n "${DEBUG:-}" ]; then set -x; fi
    CDPATH='' cd -- "$(dirname -- "${0}")" > /dev/null 2>&1
    pwd="$(pwd)"
    wget -q -O "${pwd}/$(basename -- "${0}")" \
      "https://raw.githubusercontent.com/${1}/wget_me.sh"
  )

  # shellcheck disable=2317
  # SC2317: Command appears to be unreachable => reached indirectly into the trap statement
  trap_me ()
  {
    if [ -n "${DEBUG:-}" ]; then set -x; fi
    docker compose --file "${1}/compose.yaml" stop --timeout 0 || :
    docker compose --file "${1}/compose.yaml" rm --force || :

    # shellcheck disable=2016
    # SC2016: Expressions don't expand in single quotes, use double quotes for that => expansion not needed
    source_env_without_docker_host "${1}" \
      'docker volume rm $(docker volume list --filter "name=${DELETE_ME_SFX}" --format "{{ .Name }}")' || :
    rm -rf "${1}"
    update_me "${2}/${3}"
  }

  harden basename
  harden cp
  harden diff
  harden dirname
  harden grep
  harden find
  harden mkdir
  harden mktemp
  harden pidof
  harden rm
  harden tr
  harden sed
  harden sleep
  harden sort
  harden sudo
  harden uniq
  harden wget

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

  if [ ! -f /etc/os-release ]
  then
    printf 'Can not find /etc/os-release. The OS where this script is running is probably not officialy supported by Docker.\n' >&2
    return 1
  fi

  if ! command -v docker > /dev/null; then wget -q -O- https://get.docker.com | sudo sh; fi

  harden docker

  dist="$(. /etc/os-release && printf '%s\n' "${ID}")"
  readonly dist

  case "${dist}" in
  ( 'ubuntu'|'debian' )
    harden apt-get apt_get sudo
    apt_get update -y
    apt_get upgrade -y ;;
  ( 'alpine' )
    harden apk apk sudo
    apk update
    apk upgrade ;;
  ( * )
    printf 'Can not update Docker packages: unknown OS: %s\n' "${dist}" >&2
    return 1 ;;
  esac

  tmp="$(mktemp --directory)"
  dir_tmp="$(dirname "${tmp}")"
  base_tmp="$(basename "${tmp}")"
  repo='tiawl/MyWhaleFleet'
  repo_url="https://github.com/${repo}.git"
  readonly tmp dir_tmp base_tmp repo repo_url

  git clone --depth 1 --branch "${branch}" "${repo_url}" "${tmp}" || \
  docker run --rm --volume "${HOME}:/root" --volume "${dir_tmp}:/git" 'alpine/git:user' \
    clone --depth 1 --branch "${branch}" "${repo_url}" "${base_tmp}"

  daemon_json='/etc/docker/daemon.json'
  readonly daemon_json

  if pidof dockerd
  then
    if [ ! -e "${daemon_json}" ] || ! diff "${daemon_json}" "${tmp}/host/${daemon_json}" > /dev/null
    then
      sudo mkdir -p "$(dirname "${daemon_json}")"
      sudo cp -f "${tmp}/host/${daemon_json}" "${daemon_json}"
      if command -v systemctl > /dev/null
      then
        harden systemctl
        sudo systemctl restart docker
      elif command -v service > /dev/null
      then
        harden service
        sudo service docker restart
      else
        printf 'Can not restart Dockerd: unknown service manager\n' >&2
        return 1
      fi
    fi
  fi

  API_TAG="$(docker version --format '{{ .Server.APIVersion }}')"
  export API_TAG

  local_img_sfx="$(set -a; . "${tmp}/env.d/00init.sh"; . "${tmp}/env.d/01id.sh"; printf '%s\n' "${LOCAL_IMG_SFX}")"
  readonly local_img_sfx

  for var in $(set | grep "^${local_img_sfx}='")
  do
    unset "${var%%=*}"
  done
  unset var

  trap 'trap_me "${tmp}" "${repo}" "${branch}"' EXIT

  find "${tmp}" -type f -name compose.yaml.in -exec sh -c '
      set -a
      . "${1}/env.sh"
      eval "printf \"%s\\n\" \"$(cat "${2}")\"" > "${2%.*}"
    ' sh "${tmp}" {} \;

  docker network prune --force

  source_env_without_docker_host "${tmp}" \
    'for local_img in $(set | grep "^${LOCAL_IMG_SFX}='"'"'")
     do
       target="${local_img%%=*}"
       src="${local_img%%"${LOCAL_IMG_SFX}"=*}${IMG_SFX}"
       tag="${local_img%%"${LOCAL_IMG_SFX}"=*}${TAG_SFX}"
       eval "docker tag \"\${${src}}:\${${tag}}\" \"\${${target}}:\${${tag}}\""
     done'

  docker compose --file "${tmp}/components/compose.yaml" build
  docker compose --file "${tmp}/compose.yaml" build
  docker compose --file "${tmp}/compose.yaml" create --no-recreate
  docker compose --file "${tmp}/compose.yaml" start
  printf 'Sleeping ...\n'
  sleep 3

  running_services="$(docker compose --file "${tmp}/compose.yaml" ps --filter 'status=running' --format '{{ .Names }}')"
  services="$(docker compose --file "${tmp}/compose.yaml" config --services)"
  readonly running_services services

  set -f
  # shellcheck disable=2086
  # SC2086: Double quote to prevent globbing and word splitting => globbing disabled & word splitting needed
  failed_services="$(printf '%s\n' ${running_services} ${services} | sort | uniq -u)"
  set +f
  readonly failed_services

  if [ -n "${failed_services}" ]
  then
    set -f
    # shellcheck disable=2086
    # SC2086: Double quote to prevent globbing and word splitting => globbing disabled & word splitting needed
    printf 'This service failed: %s\n' ${failed_services} >&2
    set +f
    return 1
  fi

  docker volume prune --all --force
  docker image prune --force > /dev/null

  # shellcheck disable=2016
  # SC2016: Expressions don't expand in single quotes, use double quotes for that => expansion not needed
  source_env_without_docker_host "${tmp}" \
    'docker logs "${PROXY_SERVICE}" 2> /dev/null | sed -n "/^-----\+$/,/^-----\+$/p"'

  if [ "${runner}" != "${bot}" ]
  then
    source_env_without_docker_host "${tmp}" \
      "docker compose --file '${tmp}/compose.yaml' attach \"\${JUMPER_SERVICE}\""
  fi
)

case "${-}" in ( *x* ) DEBUG=true ;; ( * ) DEBUG='' ;; esac; \command readonly DEBUG 

main "${@}"

exit
}
