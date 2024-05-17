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

upper ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  printf '%s\n' "${1}" | tr '[:lower:]' '[:upper:]'
}

sfx ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  upper "_${1}"
}

id ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  eval "${1}$(sfx 'id' || :)='${2}'"
}

upper_id ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  id "$(upper "${1}" || :)" "${1}"
}

component_id ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  id "$(upper "${1}" || :)$(sfx "${COMPONENT_ID}" || :)" "${COMPONENT_ID}${ID_SEP}${1}"
}

explorer_id ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  id "$(upper "${1}" || :)$(sfx "${EXPLORER_ID}" || :)" "${EXPLORER_ID}${ID_SEP}${1}"
}

_img ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  eval "$(upper "${1}" || :)$(sfx 'img' || :)='${2}/${3}:${4}'"
}

intern_img ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  _img "${1}" "${OWNER_ID}" "${1}" "${2}"
}

component_img ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  _img "${1}$(sfx "${COMPONENT_ID}" || :)" "${OWNER_ID}" "${1}" "${2}"
}

extern_img ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  _img "${1}" "${2}" "${3}" "${4}"
  _img "${1}$(sfx 'local' || :)" "${OWNER_ID}" "local/${3}" "${4}"
}

_host ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  eval "$(upper "${1}" || :)$(sfx 'host' || :)='${2}'"
}

host ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  _host "${1}" "${1}"
}

explorer_host ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  _host "$(upper "${1}" || :)$(sfx "${EXPLORER_ID}" || :)" "${EXPLORER_ID}${HOST_SEP}${1}"
}

path ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  eval "$(upper "${1}" || :)$(sfx 'path' || :)='${2}'"
}

_service ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  eval "$(upper "${1}" || :)$(sfx 'service' || :)='${2}'"
}

service ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  _service "${1}" "${1}"
}

explorer_service ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  _service "$(upper "${1}" || :)$(sfx "${EXPLORER_ID}" || :)" "${EXPLORER_ID}${SERVICE_SEP}${1}"
}

tag ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  eval "$(upper "${1}" || :)$(sfx 'tag' || :)='${2}'"
}

component_tag ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  tag "${1}$(sfx "${COMPONENT_ID}" || :)" "${2}"
}

url ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  eval "$(upper "${1}" || :)$(sfx 'url' || :)='${2}'"
}

_volume ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi
  eval "$(upper "${1}" || :)$(sfx 'volume' || :)='${2}'"
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
