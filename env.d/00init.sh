#! /bin/sh

FALSE='0'
TRUE='1'
APK_PATHS='/sbin/apk /etc/apk /lib/apk /usr/share/apk /var/lib/apk'
COMPOSE_PROJECT_NAME='mywhalefleet'
OS='alpine'
UNPRIVILEGED_USER='visitor'

API_PFX='API_ENDPOINT_'
ID_SEP='/'
HOST_SEP='.'
SERVICE_SEP='.'
DELETE_ME_SFX='-DELME'

upper () { printf '%s\n' "${1}" | tr 'a-z' 'A-Z'; }
sfx () { upper "_${1}"; }

id () { eval "${1}$(sfx 'id')='${2}'"; }
ID () { id "$(upper "${1}")" "${1}";}
component_id () { id "$(upper "${1}")$(sfx "${COMPONENT_ID}")" "${COMPONENT_ID}${ID_SEP}${1}"; }
explorer_id () { id "$(upper "${1}")$(sfx "${EXPLORER_ID}")" "${EXPLORER_ID}${ID_SEP}${1}"; }

_img () { eval "$(upper "${1}")$(sfx 'img')='${2}/${3}:${4}'"; }
intern_img () { _img "${1}" "${OWNER_ID}" "${1}" "${2}"; }
extern_img ()
{
  _img "${1}" "${2}" "${3}" "${4}"
  _img "${1}$(sfx 'local')" "${OWNER_ID}" "local/${3}" "${4}"
}

_host () { eval "$(upper "${1}")$(sfx 'host')='${2}'"; }
host () { _host "${1}" "${1}"; }
explorer_host () { _host "$(upper "${1}")$(sfx "${EXPLORER_ID}")" "${EXPLORER_ID}${HOST_SEP}${1}"; }

path () { eval "$(upper "${1}")$(sfx 'path')='${2}'"; }

_service () { eval "$(upper "${1}")$(sfx 'service')='${2}'"; }
service () { _service "${1}" "${1}"; }
explorer_service () { _service "$(upper "${1}$(sfx "${EXPLORER_ID}")")" "${EXPLORER_ID}${SERVICE_SEP}${1}"; }

tag () { eval "$(upper "${1}")$(sfx 'tag')='${2}'"; }
component_tag () { tag "${1}$(sfx "${COMPONENT_ID}")" "${2}"; }

url () { eval "$(upper "${1}")$(sfx 'url')='${2}'"; }

_volume () { eval "$(upper "${1}")$(sfx 'volume')='${2}'"; }
volume () { _volume "${1}" "${1}"; }
delme_volume () { _volume "${1}" "${2}{DELETE_ME_SFX}"; }
