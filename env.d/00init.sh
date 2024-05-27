#! /bin/sh
# shellcheck disable=2034,2154
# SC2034: VAR appears unused => VAR used for templating
# SC2154: VAR is referenced but not assigned => VAR is assigned with eval statement in 01init.sh function

FALSE='0'
TRUE='1'
APK_PATHS='/sbin/apk /etc/apk /lib/apk /usr/share/apk /var/lib/apk'
COMPOSE_PROJECT_NAME='mywhalefleet'
UNPRIVILEGED_USER='visitor'

API_PFX='API_ENDPOINT_'
ID_SEP='/'
IMG_SEP='.'
TAG_SEP=':'
HOST_SEP='.'
SERVICE_SEP='.'
DELETE_ME_SFX='-DELME'
SFX='_SFX'

_upper ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  while [ -n "${1}" ]
  do
    case "${1%"${1#?}"}" in
    ( a ) set -- "${1#?}" "${2:-}A" ;;
    ( b ) set -- "${1#?}" "${2:-}B" ;;
    ( c ) set -- "${1#?}" "${2:-}C" ;;
    ( d ) set -- "${1#?}" "${2:-}D" ;;
    ( e ) set -- "${1#?}" "${2:-}E" ;;
    ( f ) set -- "${1#?}" "${2:-}F" ;;
    ( g ) set -- "${1#?}" "${2:-}G" ;;
    ( h ) set -- "${1#?}" "${2:-}H" ;;
    ( i ) set -- "${1#?}" "${2:-}I" ;;
    ( j ) set -- "${1#?}" "${2:-}J" ;;
    ( k ) set -- "${1#?}" "${2:-}K" ;;
    ( l ) set -- "${1#?}" "${2:-}L" ;;
    ( m ) set -- "${1#?}" "${2:-}M" ;;
    ( n ) set -- "${1#?}" "${2:-}N" ;;
    ( o ) set -- "${1#?}" "${2:-}O" ;;
    ( p ) set -- "${1#?}" "${2:-}P" ;;
    ( q ) set -- "${1#?}" "${2:-}Q" ;;
    ( r ) set -- "${1#?}" "${2:-}R" ;;
    ( s ) set -- "${1#?}" "${2:-}S" ;;
    ( t ) set -- "${1#?}" "${2:-}T" ;;
    ( u ) set -- "${1#?}" "${2:-}U" ;;
    ( v ) set -- "${1#?}" "${2:-}V" ;;
    ( w ) set -- "${1#?}" "${2:-}W" ;;
    ( x ) set -- "${1#?}" "${2:-}X" ;;
    ( y ) set -- "${1#?}" "${2:-}Y" ;;
    ( z ) set -- "${1#?}" "${2:-}Z" ;;
    ( * ) set -- "${1#?}" "${2:-}${1%"${1#?}"}" ;;
    esac
  done
  printf '%s\n' "${2}"
}

_sfx ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  set -- "$(_upper "${1}" || :)"
  eval "${1}${SFX}='_${1}'"
}

_sfx 'host'
_sfx 'id'
_sfx 'img'
_sfx 'path'
_sfx 'service'
_sfx 'tag'
_sfx 'url'
_sfx 'volume'

__host ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  eval "$(case "${1}" in ( 'docker'*|'buildkit'* ) printf '_' ;; ( * ) ;; esac; _upper "${1}" || :)${SFX_OVERRIDE:-"${HOST_SFX}"}='${2}'"
}

_host ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  __host "${1}" "${1}"
}

_explorer_host ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  SFX_OVERRIDE="${EXPLORER_HOST_SFX}" __host "${1}" "${EXPLORER_ID}${HOST_SEP}${1}"
  unset SFX_OVERRIDE
}

_relay_host ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  SFX_OVERRIDE="${RELAY_HOST_SFX}" __host "${1}" "${RELAY_ID}${HOST_SEP}${1}"
  unset SFX_OVERRIDE
}

_runner_host ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  SFX_OVERRIDE="${RUNNER_HOST_SFX}" __host "${1}" "${RUNNER_ID}${HOST_SEP}${1}"
  unset SFX_OVERRIDE
}

__id ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  eval "$(case "${1}" in ( 'docker'*|'buildkit'* ) printf '_' ;; ( * ) ;; esac; _upper "${1}" || :)${SFX_OVERRIDE:-"${ID_SFX}"}='${2}'"
}

_id ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  __id "${1}" "${1}"
}

__img ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  eval "$(case "${1}" in ( 'docker'*|'buildkit'* ) printf '_' ;; ( * ) ;; esac; _upper "${1}" || :)${SFX_OVERRIDE:-"${IMG_SFX}"}='${2}${IMG_SEP}${3}${TAG_SEP}${4}'"
}

_intern_img ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  __img "${1}" "${OWNER_ID}" "${1}" "${2}"
}

_component_img ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  SFX_OVERRIDE="${COMPONENT_IMG_SFX}" __img "${1}" "${OWNER_ID}" "${COMPONENT_ID}${IMG_SEP}${1}" "${2}"
  unset SFX_OVERRIDE
}

_relay_img ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  SFX_OVERRIDE="${RELAY_IMG_SFX}" __img "${1}" "${OWNER_ID}" "${RELAY_ID}${IMG_SEP}${1}" "${2}"
  unset SFX_OVERRIDE
}

_runner_img ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  SFX_OVERRIDE="${RUNNER_IMG_SFX}" __img "${1}" "${OWNER_ID}" "${RUNNER_ID}${IMG_SEP}${1}" "${2}"
  unset SFX_OVERRIDE
}

_extern_img ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  __img "${1}" "${2}" "${3}" "${4}"
  SFX_OVERRIDE="${LOCAL_IMG_SFX}" __img "${1}" "${OWNER_ID}" "${LOCAL_ID}${IMG_SEP}${3}" "${4}"
  unset SFX_OVERRIDE
}

_path ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  eval "$(case "${1}" in ( 'docker'*|'buildkit'* ) printf '_' ;; ( * ) ;; esac; _upper "${1}" || :)${SFX_OVERRIDE:-"${PATH_SFX}"}='${2}'"
}

__service ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  eval "$(case "${1}" in ( 'docker'*|'buildkit'* ) printf '_' ;; ( * ) ;; esac; _upper "${1}" || :)${SFX_OVERRIDE:-"${SERVICE_SFX}"}='${2}'"
}

_service ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  __service "${1}" "${1}"
}

_explorer_service ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  SFX_OVERRIDE="${EXPLORER_SERVICE_SFX}" __service "${1}" "${EXPLORER_ID}${SERVICE_SEP}${1}"
  unset SFX_OVERRIDE
}

_tag ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  eval "$(case "${1}" in ( 'docker'*|'buildkit'* ) printf '_' ;; ( * ) ;; esac; _upper "${1}" || :)${SFX_OVERRIDE:-"${TAG_SFX}"}='${2}'"
}

_component_tag ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  SFX_OVERRIDE="${COMPONENT_TAG_SFX}" _tag "${1}" "${2}"
  unset SFX_OVERRIDE
}

_url ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  eval "$(case "${1}" in ( 'docker'*|'buildkit'* ) printf '_' ;; ( * ) ;; esac; _upper "${1}" || :)${SFX_OVERRIDE:-"${URL_SFX}"}='${2}'"
}

__volume ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  eval "$(case "${1}" in ( 'docker'*|'buildkit'* ) printf '_' ;; ( * ) ;; esac; _upper "${1}" || :)${SFX_OVERRIDE:-"${VOLUME_SFX}"}='${2}'"
}

_volume ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  __volume "${1}" "${1}"
}

_delme_volume ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  __volume "${1}" "${2}${DELETE_ME_SFX}"
}
