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

upper ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  printf '%s\n' "${1}" | tr '[:lower:]' '[:upper:]'
}

sfx ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  set -- "$(upper "${1}" || :)"
  eval "${1}${SFX}='_${1}'"
}

sfx 'host'
sfx 'id'
sfx 'img'
sfx 'path'
sfx 'service'
sfx 'tag'
sfx 'url'
sfx 'volume'

_host ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  eval "$(upper "${1}" || :)${SFX_OVERRIDE:-"${HOST_SFX}"}='${2}'"
}

host ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  _host "${1}" "${1}"
}

explorer_host ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  SFX_OVERRIDE="${EXPLORER_HOST_SFX}" _host "${1}" "${EXPLORER_ID}${HOST_SEP}${1}"
  unset SFX_OVERRIDE
}

_id ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  eval "$(upper "${1}" || :)${SFX_OVERRIDE:-"${ID_SFX}"}='${2}'"
}

id ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  _id "${1}" "${1}"
}

component_id ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  SFX_OVERRIDE="${COMPONENT_ID_SFX}" _id "${1}" "${COMPONENT_ID}${ID_SEP}${1}"
  unset SFX_OVERRIDE
}

explorer_id ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  SFX_OVERRIDE="${EXPLORER_ID_SFX}" _id "${1}" "${EXPLORER_ID}${ID_SEP}${1}"
  unset SFX_OVERRIDE
}

_img ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  eval "$(upper "${1}" || :)${SFX_OVERRIDE:-"${IMG_SFX}"}='${2}/${3}:${4}'"
}

intern_img ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  _img "${1}" "${OWNER_ID}" "${1}" "${2}"
}

component_img ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  SFX_OVERRIDE="${COMPONENT_IMG_SFX}" _img "${1}" "${OWNER_ID}" "${1}" "${2}"
  unset SFX_OVERRIDE
}

extern_img ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  _img "${1}" "${2}" "${3}" "${4}"
  SFX_OVERRIDE="${LOCAL_IMG_SFX}" _img "${1}" "${OWNER_ID}" "${LOCAL_ID}/${3}" "${4}"
  unset SFX_OVERRIDE
}

path ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  eval "$(upper "${1}" || :)${SFX_OVERRIDE:-"${PATH_SFX}"}='${2}'"
}

_service ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  eval "$(upper "${1}" || :)${SFX_OVERRIDE:-"${SERVICE_SFX}"}='${2}'"
}

service ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  _service "${1}" "${1}"
}

explorer_service ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  SFX_OVERRIDE="${EXPLORER_SERVICE_SFX}" _service "${1}" "${EXPLORER_ID}${SERVICE_SEP}${1}"
  unset SFX_OVERRIDE
}

tag ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  eval "$(upper "${1}" || :)${SFX_OVERRIDE:-"${TAG_SFX}"}='${2}'"
}

component_tag ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  SFX_OVERRIDE="${COMPONENT_TAG_SFX}" tag "${1}" "${2}"
  unset SFX_OVERRIDE
}

url ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  eval "$(upper "${1}" || :)${SFX_OVERRIDE:-"${URL_SFX}"}='${2}'"
}

_volume ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  eval "$(upper "${1}" || :)${SFX_OVERRIDE:-"${VOLUME_SFX}"}='${2}'"
}

volume ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  _volume "${1}" "${1}"
}

delme_volume ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  _volume "${1}" "${2}${DELETE_ME_SFX}"
}
