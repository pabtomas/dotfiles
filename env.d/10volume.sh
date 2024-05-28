#! /bin/sh
# shellcheck disable=2034,2154
# SC2034: VAR appears unused => VAR used for templating
# SC2154: VAR is referenced but not assigned => VAR is assigned with eval statement in 01init.sh function

_volume "${COMPOSE_PROJECT_NAME}"
_volume "${SPACEPORN_ID}"
_volume "${SAFEDEPOSIT_ID}"

_delme_volume "${PROXY_ID}_etc_nginx" "${PROXY_ID}-etc-nginx-fs"
_delme_volume "${PROXY_ID}_opt_scripts" "${PROXY_ID}-opt-scripts-fs"
_delme_volume "${PROXY_ID}_var_log_nginx" "${PROXY_ID}-var-log-nginx-fs"
_delme_volume "${LISTENER_ID}_opt_data" "${LISTENER_ID}-opt-data-fs"
_delme_volume "${LISTENER_ID}_opt_scripts" "${LISTENER_ID}-opt-scripts-fs"
_delme_volume 'ssh' 'shared-ssh'
_delme_volume "${RELAY_ID}_${XSERVER_ID}_socket" "${RELAY_ID}-${XSERVER_ID}-socket"
_delme_volume "${RELAY_ID}_var_log" "${RELAY_ID}-var-log-fs"
_delme_volume "${XSERVER_ID}_etc_nginx" "${XSERVER_ID}-etc-nginx-fs"
_delme_volume "${XSERVER_ID}_opt_scripts" "${XSERVER_ID}-opt-scripts-fs"
_delme_volume "${XSERVER_ID}_var_log_nginx" "${XSERVER_ID}-var-log-nginx-fs"
_delme_volume 'theme' 'theme'
