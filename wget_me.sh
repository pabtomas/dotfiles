#! /bin/sh
## workaround to update shell script when executed: https://stackoverflow.com/a/2358432
{

## Posix shell: no local variables => subshell instead of braces
main ()
(
  ## oksh/loksh: debugtrace does not follow in functions
  if [ -n "${DEBUG:-}" ]; then \command set -x; fi

  ## shell scripting: always consider the worst env when your script is running
  ## part 1: unalias everything
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

  ## shell scripting: always consider the worst env when your script is running
  ## part 2: remove already defined functions
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

  ## cleanup done: now it is time to define needed functions

  ## zsh has a which builtin. ksh93u+m has a sleep builtin.
  ## this is a simple way to standardize external tools usage the script can not dockerize whatever the shell used to run this script:
  ## 1) ignore shell builtins with the specified name
  ## 2) fail if no external tool exists with the specified name
  ## 3) wrap the external tool with the specified name
  harden ()
  {
    ## oksh/loksh: debugtrace does not follow in functions
    if [ -n "${DEBUG:-}" ]; then set -x; fi

    IFS=':'
    for dir in ${PATH}
    do
      if [ -x "${dir}/${1}" ]
      then
        eval "${2:-"${1}"} () { ${3:+sudo }${dir}/${1} \"\${@}\"; }"
        flag='true'
        break
      fi
    done
    IFS="${old_ifs}"
    unset dir

    if [ "${flag:-}" != 'true' ]
    then
      printf 'This script needs "%s" but can not find it\n' "${1}" >&2
      return 1
    fi
    unset flag
  }

  build ()
  {
    ## oksh/loksh: debugtrace does not follow in functions
    if [ -n "${DEBUG:-}" ]; then set -x; fi

    uid="$(id -u)"
    docker build --tag "tiawl/wget_me/busybox:latest" --file - . << EOF
FROM ${1}

RUN <<END_OF_RUN
    apk --no-cache add git
    rm -rf /var/lib/apt/lists/* /var/cache/apk/*
    adduser -D -s /bin/sh -g '${new_user}' -u '${uid}' '${new_user}'
END_OF_RUN

USER ${new_user}

WORKDIR /home/${new_user}

CMD ["busybox", "sh"]
EOF
  }

  dockerize ()
  {
    ## oksh/loksh: debugtrace does not follow in functions
    if [ -n "${DEBUG:-}" ]; then set -x; fi
    eval "${1} ()
      {
        if ! docker run \${cwd:+\"--volume\"} \${cwd:+\"\${cwd}:/home/${new_user}/\"} \
          \${match:+\"--volume\"} \${match:+\"\${match}:\${match}\"} \
          \${match2:+\"--volume\"} \${match2:+\"\${match2}:\${match2}\"} \
          \${sudo:+\"--user\"} \${sudo:+\"root\"} \
          --rm --interactive 'tiawl/wget_me/busybox' ${1} \"\${@}\"
        then
          unset cwd match match2 sudo
          return 1
        else
          unset cwd match match2 sudo
        fi
      }"
  }

  ## Posix shell: no local variables => subshell instead of braces
  ## unset DOCKET_HOST after sourcing variables needed in templated to avoid conflicts with docker client
  source_env_without_docker_host ()
  (
    ## oksh/loksh: debugtrace does not follow in functions
    if [ -n "${DEBUG:-}" ]; then set -x; fi

    API_TAG="$(docker version --format '{{ .Server.APIVersion }}')"
    export API_TAG
    . "${1}/env.sh"
    eval "${2}"
  )

  ## Posix shell: no local variables => subshell instead of braces
  ## Update the script after execution
  # shellcheck disable=2317
  # SC2317: Command appears to be unreachable => reached indirectly into the trap statement
  update_me ()
  (
    ## oksh/loksh: debugtrace does not follow in functions
    if [ -n "${DEBUG:-}" ]; then set -x; fi

    CDPATH='' cd -- "$(dirname -- "${0}")" > /dev/null 2>&1
    pwd="$(pwd)"
    match="${pwd}" wget -q -O "${pwd}/$(basename -- "${0}")" \
      "https://raw.githubusercontent.com/${1}/wget_me.sh"
  )

  # shellcheck disable=2317
  # SC2317: Command appears to be unreachable => reached indirectly into the trap statement
  trap_me ()
  {
    ## oksh/loksh: debugtrace does not follow in functions
    if [ -n "${DEBUG:-}" ]; then set -x; fi

    docker compose --file "${1}/compose.yaml" stop --timeout 0 || :
    docker compose --file "${1}/compose.yaml" rm --force || :

    kill "${4}" || kill -9 "${4}"

    # shellcheck disable=2016
    # SC2016: Expressions don't expand in single quotes, use double quotes for that => expansion not needed
    source_env_without_docker_host "${1}" \
      'docker volume rm $(docker volume list --filter "name=${DELETE_ME_SFX}" --format "{{ .Name }}")' || :
    match="$(dirname -- "${1}")" rm -rf "${1}"
    match="$(dirname -- "${5}")" rm -rf "${5}"
    update_me "${2}/${3}"
  }

  bot='bot'
  readonly bot

  ## parse options
  while [ "${#}" != '0' ]
  do
    case "${1}" in
    ( '--runner-is-a-bot' ) runner="${bot}"; shift 1 ;;
    ( '--branch' ) branch="${2}"; shift 2 ;;
    ( * ) printf 'Unknown flag: "%s"\n' "${1}" >&2; return 1 ;;
    esac
  done

  ## options fallback
  branch="${branch:-trunk}"
  runner="${runner:-someone}"
  readonly branch runner

  if [ ! -f /etc/os-release ]
  then
    ## get_distribution () comment into https://get.docker.com/ script
    printf 'Can not find /etc/os-release. The OS where this script is running is probably not officialy supported by Docker.\n' >&2
    return 1
  fi

  harden sudo
  harden wget
  harden id

  # install docker
  if [ ! -e "$(command -v docker 2> /dev/null || :)" ]; then wget -q -O- https://get.docker.com | sudo sh; fi

  # check docker installation
  harden docker

  dist="$(. /etc/os-release && printf '%s\n' "${ID}")"
  readonly dist

  # update docker to the last version depending of the OS
  set +e
  case "${dist}" in
  ( 'ubuntu'|'debian' )
    harden apt-get apt_get sudo
    apt_get update -y
    apt_get upgrade -y
    apt_get install xserver-xephyr xinit x11-xkb-utils -y ;;
  ( 'alpine' )
    harden apk apk sudo
    apk update
    apk upgrade
    apk add xorg-server-xephyr xinit setxkbmap xkbcomp;;
  ( * )
    printf 'Can not update Docker or install Xephyr packages: unknown OS: %s\n' "${dist}" >&2 ;;
  esac
  set -e

  # check X utils
  harden Xephyr xephyr
  harden xinit
  harden setxkbmap
  harden xkbcomp
  harden kill

  XEPHYR_DISPLAY='0'
  while [ -e "/tmp/.X11-unix/X${XEPHYR_DISPLAY}" ]
  do
    XEPHYR_DISPLAY="$(( XEPHYR_DISPLAY + 1 ))"
  done
  readonly XEPHYR_DISPLAY
  export XEPHYR_DISPLAY

  src_tag='3.20'
  src_img="alpine:${src_tag}"
  target="tiawl/local/${src_img}"

  if ! docker image inspect "${src_img}" --format='Image found'
  then
    docker pull "${src_img}"
  fi
  docker tag "${src_img}" "${target}"
  unset src_tag src_img

  ## dockerize external tools to keep same behavior wherever the script is running
  new_user='visitor'
  build "${target}"
  unset target

  dockerize basename
  dockerize cp
  dockerize dirname
  dockerize git git
  dockerize grep
  dockerize mkdir
  dockerize mktemp
  dockerize rm
  dockerize sed
  dockerize sleep
  dockerize sort
  dockerize uniq
  dockerize wget
  unset new_user

  tmp="$(match='/tmp/' mktemp --directory '/tmp/tmp.XXXXXXXX')"
  xinitrc="$(match='/tmp/' mktemp '/tmp/tmp.XXXXXXXX')"
  repo='tiawl/MyWhaleFleet'
  repo_url="https://github.com/${repo}.git"
  readonly tmp repo repo_url xinitrc

  match="$(dirname -- "${tmp}")" git clone --depth 1 --branch "${branch}" "${repo_url}" "${tmp}"

  local_img_sfx="$(
    set -a
    . "${tmp}/env.d/00init.sh"
    . "${tmp}/env.d/01id.sh"
    printf '%s\n' "${LOCAL_IMG_SFX}"
  )"
  readonly local_img_sfx

  ## shell scripting: always consider the worst env when your script is running
  ## part 3: make the script fail if it can not unset readonly env variables using the naming convention
  for var in $(set | grep "^[^=[:space:]]\+${local_img_sfx}=")
  do
    unset "${var%%=*}"
  done
  unset var

  daemon_json='/etc/docker/daemon.json'
  daemon_conf="${tmp}/host/${daemon_json#/}"
  readonly daemon_json daemon_conf

  daemon_dir="$(dirname -- "${daemon_json}")"
  conf_dir="$(dirname -- "${daemon_conf}")"
  if [ ! -e "${daemon_json}" ] || match="${daemon_dir}" match2="${conf_dir}" grep -Fxvf "${daemon_json}" "${daemon_conf}" > /dev/null
  then
    sudo='true' match="$(dirname -- "${daemon_dir}")" mkdir -p "${daemon_dir}"
    sudo='true' match="${conf_dir}" match2="${daemon_dir}" cp -f "${daemon_conf}" "${daemon_json}"
    if [ -e "$(command -v systemctl 2> /dev/null || :)" ]
    then
      harden systemctl
      sudo systemctl restart docker
    elif [ -e "$(command -v service 2> /dev/null || :)" ]
    then
      harden service
      sudo service docker restart
    else
      printf 'Can not restart Dockerd: unknown service manager\n' >&2
      return 1
    fi
  fi
  unset daemon_dir conf_dir

  kbmap="$(setxkbmap -display "${DISPLAY}" -print)"
  readonly kbmap
  # shellcheck disable=2016
  # SC2016: Expressions don't expand in single quotes, use double quotes for that => expansion not needed
  printf '#! /bin/sh\n\nDISPLAY=%s\nexport DISPLAY\nprintf %s | xkbcomp - "${DISPLAY}"\n%s\n' "':${XEPHYR_DISPLAY}'" "'${kbmap}\n'" "${window_manager:-gdm3}"

  xinit "${xinitrc}" -- xephyr ":${XEPHYR_DISPLAY}" -extension MIT-SHM -extension XTEST -retro -resizeable &
  xinit_pid="${!}"
  readonly xinit_pid

  sleep 1

  trap 'trap_me "${tmp}" "${repo}" "${branch}" "${xinit_pid}" "${xinitrc}"' EXIT

  ## generate templated files
  API_TAG="$(docker version --format '{{ .Server.APIVersion }}')"
  (
    set -a -- "${tmp}"
    . "${tmp}/env.sh"
    for template in "${tmp}/components/compose.yaml.in" "${tmp}/compose.yaml.in"
    do
      cat="$(IFS='
'; while read -r line; do printf '%s\n' "${line}"; done < "${template}")"
      eval "printf '%s\\n' \"${cat}\"" > "${template%.*}"
    done
  )
  unset API_TAG

  docker network prune --force

  ## use local images if already downloaded: https://stackoverflow.com/a/70483395
  # shellcheck disable=2016
  # SC2016: Expressions don't expand in single quotes, use double quotes for that => expansion not needed
  source_env_without_docker_host "${tmp}" \
    'local_imgs="$(set | grep "^[^= ]\+${LOCAL_IMG_SFX}=")"
     for local_img in ${local_imgs}
     do
       target="$(eval "printf \"%s\n\" \"\${${local_img%%=*}}\"")"
       src="$(eval "printf \"%s\n\" \"\${${local_img%%"${LOCAL_IMG_SFX}"=*}${IMG_SFX}}\"")"
       if ! docker image inspect "${src}" --format="Image found"
       then
         docker pull "${src}"
       fi
       docker tag "${src}" "${target}"
     done'

  docker compose --file "${tmp}/components/compose.yaml" build
  docker compose --file "${tmp}/compose.yaml" build
  docker compose --file "${tmp}/compose.yaml" create --no-recreate
  docker compose --file "${tmp}/compose.yaml" start

  ## let a short time before checking services status
  if [ "${runner}" = "${bot}" ]
  then
    printf 'Sleeping ...\n'
    sleep 3
  fi

  running_services="$(docker compose --file "${tmp}/compose.yaml" ps --filter 'status=running' --format '{{ .Names }}')"
  services="$(docker compose --file "${tmp}/compose.yaml" config --services)"
  readonly running_services services

  set -f
  # shellcheck disable=2086
  # SC2086: Double quote to prevent globbing and word splitting => globbing disabled & word splitting needed
  failed_services="$(printf '%s\n' ${running_services} ${services} | sort | uniq -u)"
  set +f
  readonly failed_services

  ## make the script fail if a service is not running
  if [ -n "${failed_services}" ]
  then
    set -f
    # shellcheck disable=2086
    # SC2086: Double quote to prevent globbing and word splitting => globbing disabled & word splitting needed
    for failed in ${failed_services}
    do
      printf 'This service failed: %s\n' "${failed}" >&2
      docker logs "${failed}"
    done
    set +f
    unset failed
    return 1
  fi

  docker volume prune --all --force
  docker image prune --force > /dev/null

  ## Output the docker API used by the docker daemon
  # shellcheck disable=2016
  # SC2016: Expressions don't expand in single quotes, use double quotes for that => expansion not needed
  source_env_without_docker_host "${tmp}" \
    'docker logs "${PROXY_SERVICE}" 2> /dev/null | sed -n "/^-----\+$/,/^-----\+$/p"'

  ## Attach to the workspace
  if [ "${runner}" != "${bot}" ]
  then
    source_env_without_docker_host "${tmp}" \
      "docker compose --file '${tmp}/compose.yaml' attach \"\${JUMPER_SERVICE}\""
  fi
)

## oksh/loksh: debugtrace does not follow in functions
case "${-}" in ( *x* ) DEBUG='true' ;; ( * ) DEBUG='' ;; esac; \command readonly DEBUG 

main "${@}"

## workaround to update shell script when executed: https://stackoverflow.com/a/2358432
exit
}
