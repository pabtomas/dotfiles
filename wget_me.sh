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

  parse_options ()
  {
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
  }

  ## zsh has a which builtin. ksh93u+m has a sleep builtin.
  ## this is a simple way to standardize external tools usage the script can not dockerize whatever the shell used to run this script.
  ## no `which`, `command` or `whence` usage: because their behavior differ depending of the used shell
  ## 1) ignore shell builtins for the specified name
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

  install_docker ()
  {
    if [ ! -f /etc/os-release ]
    then
      ## get_distribution () comment into https://get.docker.com/ script
      printf 'Can not find /etc/os-release. The OS where this script is running is probably not officialy supported by Docker.\n' >&2
      return 1
    fi

    ## install docker
    if [ ! -e "$(command -v docker 2> /dev/null || :)" ]; then wget -q -O- https://get.docker.com | sudo sh; fi

    ## check
    harden docker
  }

  ## Posix shell: no local variables => subshell instead of braces
  update_docker ()
  (
    dist="$(. /etc/os-release && printf '%s\n' "${ID}")"
    readonly dist

    ## update docker to the last version depending of the OS
    case "${dist}" in
    ( 'ubuntu'|'debian' )
      harden apt-get apt_get sudo

      ## do not fail if internet is not available
      set +e

      apt_get update -y
      apt_get upgrade -y

      ## the function fails later if matching executable are not available
      apt_get install xserver-xephyr xinit -y
      set -e ;;
    ( 'alpine' )
      harden apk apk sudo

      ## do not fail if internet is not available
      set +e

      apk update
      apk upgrade

      ## the function fails later if matching executable are not available
      apk add xorg-server-xephyr xinit
      set -e ;;
    ( * )
      printf 'Can not update Docker or install Xephyr packages: unknown OS: %s\n' "${dist}" >&2 ;;
    esac

    ## check X utils
    harden Xephyr
    harden xinit
  )

  ## Posix shell: no local variables => subshell instead of braces
  ## build the oneshot docker image
  build ()
  (
    ## oksh/loksh: debugtrace does not follow in functions
    if [ -n "${DEBUG:-}" ]; then set -x; fi

    src_tag='3.20'
    src_img="alpine:${src_tag}"
    target="tiawl.local.${src_img}"

    ## pull the image if not if the local cache
    if ! docker image inspect "${src_img}" --format='Image found'
    then
      docker pull "${src_img}"
    fi
    docker tag "${src_img}" "${target}"

    ## define the same uid between host and image to avoid permissions issues
    uid="$(id -u)"
    docker build --tag "tiawl.wget_me.oneshot:latest" --file - . << EOF
FROM ${target}

RUN <<END_OF_RUN
    apk --no-cache add git yq findutils
    rm -rf /var/lib/apt/lists/* /var/cache/apk/* /tmp /etc/docker ${1}
    adduser -D -s /bin/sh -g '${new_user}' -u '${uid}' '${new_user}'
END_OF_RUN

USER ${new_user}

WORKDIR /home/${new_user}

CMD ["busybox", "sh"]
EOF
  )

  ## define a new function for each external tool: allow to standardize external tools for an expensive speed loss
  dockerize ()
  {
    ## oksh/loksh: debugtrace does not follow in functions
    if [ -n "${DEBUG:-}" ]; then set -x; fi

    ## cwd: mount to define the current working directory of the tool
    ## match & match2: mounts to define identical absolute path between host and container
    ## sudo: do we need root access ?
    eval "${1} ()
      {
        if ! docker run \${cwd:+\"--volume\"} \${cwd:+\"\${cwd}:/home/${new_user}/\"} \
          \${match:+\"--volume\"} \${match:+\"\${match}:\${match}\"} \
          \${match2:+\"--volume\"} \${match2:+\"\${match2}:\${match2}\"} \
          \${sudo:+\"--user\"} \${sudo:+\"root\"} \
          --rm --interactive 'tiawl.wget_me.oneshot' ${1} \"\${@}\"
        then
          unset cwd match match2 sudo
          return 1
        else
          unset cwd match match2 sudo
        fi
      }"
  }

  ## factorize reusable code
  generate_variables ()
  {
    API_TAG="$(docker version --format '{{ .Server.APIVersion }}')"
    export API_TAG
  }

  ## Posix shell: no local variables => subshell instead of braces
  ## resolve shell templates
  generate_templates ()
  (
    ## oksh/loksh: debugtrace does not follow in functions
    if [ -n "${DEBUG:-}" ]; then set -x; fi

    generate_variables
    set -a
    . "${1}/env.sh"

    for template in "${1}/anchors.yaml.in" $(match="${1}" find "${1}" -type f -name compose.yaml.in -printf '%d %p\n' | sort -n -r | cut -d ' ' -f 2) $(match="${1}" find "${1}" -type f -name '*.in' -not -name '*.yaml.in')
    do
      cat="$(IFS='
'; while read -r line; do printf '%s\n' "${line}"; done < "${template}")"
      eval "printf '%s\\n' \"${cat}\"" > "${template%.*}"
    done
  )

  ## Posix shell: no local variables => subshell instead of braces
  config_host ()
  (
    etc='/etc'
    etc_docker="${etc}/docker"
    conf_dir="${1}/host/${etc_docker#/}"
    daemon_json="${etc_docker}/daemon.json"
    daemon_conf="${conf_dir}/daemon.json"
    readonly daemon_json daemon_conf conf_dir etc etc_docker

    ## copy docker daemon config to the host and restart daemon
    if [ ! -e "${daemon_json}" ] || match="${etc_docker}" match2="${conf_dir}" grep -Fxvf "${daemon_json}" "${daemon_conf}" > /dev/null
    then
      sudo='true' match="${etc}" mkdir -p "${etc_docker}"
      sudo='true' match="${conf_dir}" match2="${etc_docker}" cp -f "${daemon_conf}" "${daemon_json}"
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
  )

  ## must be call before any sourcing of env.sh because it needs XEPHYR_DISPLAY
  open_display ()
  {
    ## search the first available display
    XEPHYR_DISPLAY='0'
    while [ -e "/tmp/.X11-unix/X${XEPHYR_DISPLAY}" ]
    do
      XEPHYR_DISPLAY="$(( XEPHYR_DISPLAY + 1 ))"
    done
    readonly XEPHYR_DISPLAY
    export XEPHYR_DISPLAY

    # shellcheck disable=2016
    # SC2016: Expressions don't expand in single quotes, use double quotes for that => expansion not needed
    printf '#! /bin/sh\n\nDISPLAY=%s\nexport DISPLAY\nexec %s\n' "':${XEPHYR_DISPLAY}'" "${WM:-awesome}" > "${1}"

    ## resolve Xephyr absolute path for xinit
    _xephyr="$(IFS=':'
               for dir in ${PATH}
               do
                 if [ -x "${dir}/Xephyr" ]
                 then
                   printf '%s\n' "${dir}/Xephyr"
                   break
                 fi
               done)"
    xinit "${1}" -- "${_xephyr}" ":${XEPHYR_DISPLAY}" -extension MIT-SHM -extension XTEST -resizeable > /dev/null 2>&1 &
    unset _xephyr
  }

  ## Posix shell: no local variables => subshell instead of braces
  ## Use local images if already downloaded: https://stackoverflow.com/a/70483395
  generate_local_tags ()
  (
    ## oksh/loksh: debugtrace does not follow in functions
    if [ -n "${DEBUG:-}" ]; then set -x; fi

    generate_variables
    set -a
    . "${1}/env.sh"

    # shellcheck disable=2153,2154
    # SC2153: Possible misspelling LOCAL_IMG_SFX => not it is not
    # SC2154: VAR is referenced but not assigned => assigned into env.sh
    local_imgs="$(set | grep "^[^= ]\+${LOCAL_IMG_SFX}=")"
    for local_img in ${local_imgs}
    do
      target="$(eval "printf '%s\n' \"\${${local_img%%=*}}\"")"

      # shellcheck disable=2154
      # SC2154: VAR is referenced but not assigned => assigned into env.sh
      src="$(eval "printf '%s\n' \"\${${local_img%%"${LOCAL_IMG_SFX}"=*}${IMG_SFX}}\"")"

      ## pull the image if not if the local cache
      if ! docker image inspect "${src}" --format='Image found'
      then
        docker pull "${src}"
      fi
      docker tag "${src}" "${target}"
    done
  )

  ## parse exploded main compose.yaml to set check entrypoint variables
  parse_compose ()
  {
    ## add anchors.yaml before each compose.yaml because anchors' YAML can not be shared accross different files:
    ## https://github.com/docker/compose/issues/5621
    # shellcheck disable=2016
    # SC2016: Expressions don't expand in single quotes, use double quotes for that => expansion not needed
    compose_file="$(match="${1}" find "${1}" -type f -name compose.yaml -exec sh -c '
      {
        IFS="
"
        while read -r line
        do
          file="${file:-}${file:+
}${line}"
        done < "${2}/anchors.yaml"
        while read -r line
        do
          file="${file:-}${file:+
}${line}"
        done < "${1}"
        printf "%s\n" "${file}" > "${1}"
      } > /dev/null 2>&1
      if [ "${1}" = "${2}/compose.yaml" ]; then printf "%s\n" "${file}"; fi
      ' sh {} "${1}" \;)"

    ## resolve compose 'extends:' for entrypoint checks
    compose_file="$(printf '%s\n' "${compose_file}" | docker compose --file - config)"

    # shellcheck disable=2016
    # SC2016: Expressions don't expand in single quotes, use double quotes for that => expansion not needed: it is yq variables not shell variables
    _COMPOSE_ROUTES="$(printf '%s\n' "${compose_file}" | yq '.networks as $net | {.services | to_entries[] | (.key: (.value.networks | to_entries[] | .key))} | to_entries[] | (.key + " " + $net[.value].ipam.config[].subnet)' | tr '\n' ' ')"
    _COMPOSE_VOLUMES="$(printf '%s\n' "${compose_file}" | yq '.services | to_entries[] | (.key + " " + .value.volumes.[].target)' | tr '\n' ' ')"

    # shellcheck disable=2154
    # SC2154: VAR is referenced but not assigned => assigned into env.sh
    _COMPOSE_JUMP_AREA_HOSTS="$(source_env "${1}" \
      "printf '%s\\n' '${compose_file}' | yq '.services | to_entries[] | select(.value.networks | to_entries[] | select(.key==\"\${JUMP_AREA_NET}\")) | .value.hostname' | tr '\n' ' '")"
    readonly _COMPOSE_ROUTES _COMPOSE_VOLUMES _COMPOSE_JUMP_AREA_HOSTS
    export _COMPOSE_ROUTES _COMPOSE_VOLUMES _COMPOSE_JUMP_AREA_HOSTS

    unset compose_file
  }

  ## Posix shell: no local variables => subshell instead of braces
  ## unset DOCKET_HOST after sourcing variables needed in templated to avoid conflicts with docker client
  source_env ()
  (
    ## oksh/loksh: debugtrace does not follow in functions
    if [ -n "${DEBUG:-}" ]; then set -x; fi

    generate_variables
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

    match="${2}" wget -q -O "${2}/$(basename -- "${0}")" \
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

    # shellcheck disable=2016
    # SC2016: Expressions don't expand in single quotes, use double quotes for that => expansion not needed
    source_env "${1}" \
      'docker volume rm $(docker volume list --filter "name=${DELETE_ME_SFX}" --format "{{ .Name }}")' || :
    match="$(dirname -- "${1}")" rm -rf "${1}"
    match="$(dirname -- "${4}")" rm -rf "${4}"
    update_me "${2}/${3}" "${5}"
  }

  bot='bot'
  pwd="$(CDPATH='' cd -- "$(dirname -- "${0}")" > /dev/null 2>&1; pwd)"
  readonly bot pwd

  parse_options "${@}"
  set --

  harden sudo
  harden wget
  harden id
  harden sh

  install_docker

  update_docker

  ## dockerize external tools to keep same behavior wherever the script is running
  new_user='visitor'
  build "${pwd}"
  dockerize basename
  dockerize cp
  dockerize cut
  dockerize dirname
  dockerize find
  dockerize git git
  dockerize grep
  dockerize mkdir
  dockerize mktemp
  dockerize rm
  dockerize sed
  dockerize sleep
  dockerize sort
  dockerize tr
  dockerize uniq
  dockerize wget
  dockerize yq
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

  open_display "${xinitrc}"

  generate_templates "${tmp}"

  config_host "${tmp}"

  trap 'trap_me "${tmp}" "${repo}" "${branch}" "${xinitrc}" "${pwd}"' EXIT

  docker network prune --force

  generate_local_tags "${tmp}"

  parse_compose "${tmp}"

  docker compose --file "${tmp}/models/layers/compose.yaml" build --build-arg "_COMPOSE_ROUTES=${_COMPOSE_ROUTES}" --build-arg "_COMPOSE_VOLUMES=${_COMPOSE_VOLUMES}"
  docker compose --file "${tmp}/compose.yaml" build --build-arg "_COMPOSE_JUMP_AREA_HOSTS=${_COMPOSE_JUMP_AREA_HOSTS}"
  docker compose --file "${tmp}/compose.yaml" create --no-recreate
  docker compose --file "${tmp}/compose.yaml" start

  # shellcheck disable=2016
  # SC2016: Expressions don't expand in single quotes, use double quotes for that => expansion not needed
  source_env "${tmp}" \
    'docker compose --file "${tmp}/compose.yaml" exec "${JUMPER_SERVICE}" sh "${OPT_SCRIPTS_PATH}/after_entrypoint.sh"'

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
  source_env "${tmp}" \
    'docker logs "${PROXY_SERVICE}" 2> /dev/null | sed -n "/^-----\+$/,/^-----\+$/p"'

  ## Attach to the workspace
  if [ "${runner}" != "${bot}" ]
  then
    source_env "${tmp}" \
      "docker compose --file '${tmp}/compose.yaml' attach \"\${JUMPER_SERVICE}\""
  fi
)

## oksh/loksh: debugtrace does not follow in functions
case "${-}" in ( *x* ) DEBUG='true' ;; ( * ) DEBUG='' ;; esac; \command readonly DEBUG 

main "${@}"

## workaround to update shell script when executed: https://stackoverflow.com/a/2358432
exit
}
