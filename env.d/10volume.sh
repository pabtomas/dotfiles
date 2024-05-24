#! /bin/sh
# shellcheck disable=2034,2154
# SC2034: VAR appears unused => VAR used for templating
# SC2154: VAR is referenced but not assigned => VAR is assigned with eval statement in 01init.sh function

_volume "${COMPOSE_PROJECT_NAME}"
_volume "${SPACEPORN_ID}"
_volume "${SAFEDEPOSIT_ID}"

_delme_volume 'proxy_etc_nginx' "${PROXY_ID}-etc-nginx-fs"
_delme_volume 'proxy_opt_scripts' "${PROXY_ID}-opt-scripts-fs"
_delme_volume 'proxy_var_log_nginx' "${PROXY_ID}-var-log-nginx-fs"
_delme_volume 'collector_var_log' "${COLLECTOR_ID}-var-log-fs"
_delme_volume 'collector_etc_crontabs' "${COLLECTOR_ID}-etc-crontabs-fs"
_delme_volume 'collector_opt_data' "${COLLECTOR_ID}-opt-data-fs"
_delme_volume 'collector_opt_scripts' "${COLLECTOR_ID}-opt-scripts-fs"
_delme_volume 'ssh' 'shared-ssh'
