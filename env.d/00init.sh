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
HOST_SEP='.'
SERVICE_SEP='.'
DELETE_ME_SFX='-DELME'
SFX='_SFX'

_upper ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  printf '%s\n' "${1}" | tr '[:lower:]' '[:upper:]'
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
  eval "$(_upper "${1}" || :)${SFX_OVERRIDE:-"${HOST_SFX}"}='${2}'"
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

__id ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  eval "$(_upper "${1}" || :)${SFX_OVERRIDE:-"${ID_SFX}"}='${2}'"
}

_id ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  __id "${1}" "${1}"
}

_component_id ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  SFX_OVERRIDE="${COMPONENT_ID_SFX}" __id "${1}" "${COMPONENT_ID}${ID_SEP}${1}"
  unset SFX_OVERRIDE
}

_explorer_id ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  SFX_OVERRIDE="${EXPLORER_ID_SFX}" __id "${1}" "${EXPLORER_ID}${ID_SEP}${1}"
  unset SFX_OVERRIDE
}

__img ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  eval "$(_upper "${1}" || :)${SFX_OVERRIDE:-"${IMG_SFX}"}='${2}/${3}:${4}'"
}

_intern_img ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  __img "${1}" "${OWNER_ID}" "${1}" "${2}"
}

_component_img ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  SFX_OVERRIDE="${COMPONENT_IMG_SFX}" __img "${1}" "${OWNER_ID}" "${1}" "${2}"
  unset SFX_OVERRIDE
}

_extern_img ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  __img "${1}" "${2}" "${3}" "${4}"
  SFX_OVERRIDE="${LOCAL_IMG_SFX}" __img "${1}" "${OWNER_ID}" "${LOCAL_ID}/${3}" "${4}"
  unset SFX_OVERRIDE
}

_path ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  eval "$(_upper "${1}" || :)${SFX_OVERRIDE:-"${PATH_SFX}"}='${2}'"
}

__service ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  eval "$(_upper "${1}" || :)${SFX_OVERRIDE:-"${SERVICE_SFX}"}='${2}'"
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
  eval "$(_upper "${1}" || :)${SFX_OVERRIDE:-"${TAG_SFX}"}='${2}'"
}

_component_tag ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  SFX_OVERRIDE="${COMPONENT_TAG_SFX}" tag "${1}" "${2}"
  unset SFX_OVERRIDE
}

_url ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  eval "$(_upper "${1}" || :)${SFX_OVERRIDE:-"${URL_SFX}"}='${2}'"
}

__volume ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  eval "$(_upper "${1}" || :)${SFX_OVERRIDE:-"${VOLUME_SFX}"}='${2}'"
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
