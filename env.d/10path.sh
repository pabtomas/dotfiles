#! /bin/sh
# shellcheck disable=2034,2154
# SC2034: VAR appears unused => VAR used for templating
# SC2154: VAR is referenced but not assigned => VAR is assigned with eval statement in 01init.sh function

_path 'bash_aliases' '/etc/profile.d/99aliases.d'
_path 'bash_completion' '/etc/profile.d/99completion.d'
_path 'bash_theme' '/etc/profile.d/10theme.d'
_path 'bin' '/usr/local/bin'
_path 'data' '/opt/data'
_path 'docker_plugins' '/usr/local/libexec/docker/cli-plugins'
_path 'etc_nginx' '/etc/nginx'
_path 'etc_nginx_confd' "${ETC_NGINX_PATH}/conf.d"
_path 'etc_nginx_httpd' "${ETC_NGINX_PATH}/http.d"
_path 'var_log_nginx' '/var/log/nginx'
_path 'opt_scripts' '/opt/scripts'
_path 'opt_ssh' '/opt/ssh'
_path "${REGISTRY_ID}_storage" '/data'
_path "${SAFEDEPOSIT_ID}" '/root/.password-store'
_path "${_DOCKER_ID}_socket" '/var/run/docker.sock'
_path 'tmp_xserver_sockets' '/tmp/.X11-unix'
_path "${XSERVER_ID}_socket" "${TMP_XSERVER_SOCKETS_PATH}/X${XEPHYR_DISPLAY}"
_path 'ssh_root' '/root/.ssh'
_path 'tpm' '/root/.tmux/plugins/tpm'
_path 'var_log' '/var/log'
_path "${WORKSPACES_ID}" '/workspaces'
_path 'completion' "${DATA_PATH}/99completion"
_path "${ENTRYPOINT_ID}" "${OPT_SCRIPTS_PATH}/docker_entrypoint.sh"
_path 'entrypointd' "${ENTRYPOINT_PATH%/*}/$(set -- "${ENTRYPOINT_PATH##*/}"; printf '%s\n' "${1%.*}").d"
_path 'check_entrypoint' "${ENTRYPOINTD_PATH}/98check.sh"
_path 'cron_log' "${VAR_LOG_PATH}/cron.log"
_path "${COMPOSE_PROJECT_NAME}" "${WORKSPACES_PATH}/${COMPOSE_PROJECT_NAME}"
_path "${SPACEPORN_ID}" "${WORKSPACES_PATH}/${SPACEPORN_ID}"
_path 'cwd' "$(set -- "${#}" "${@}"; shift "${1}" || :; printf '%s\n' "${1}")"
_path 'components' "${CWD_PATH}/${COMPONENT_ID}s"
_path 'runners' "${CWD_PATH}/${RUNNER_ID}s"
