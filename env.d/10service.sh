#! /bin/sh
# shellcheck disable=2034,2154
# SC2034: VAR appears unused => VAR used for templating
# SC2154: VAR is referenced but not assigned => VAR is assigned with eval statement in 01init.sh function

service "${COLLECTOR_ID}"
service "${CONTROLLER_ID}"
service "${EDITOR_ID}"
service "${JUMPER_ID}"
service "${PROXY_ID}"
service "${SAFEDEPOSIT_ID}"
service "${SCHOLAR_ID}"
service "${BASH_ID}"
service "${DOCKER_ID}"
service "${ENTRYPOINT_ID}"
service "${GIT_ID}"
service "${LINGUIST_ID}"
service "${MAN_ID}"
service "${PASS_ID}"
service "${SHELL_ID}"
service "${SSHD_ID}"
service "${TMUX_ID}"
service "${VIM_ID}"
service "${WORKSPACES_ID}"
service "${ZIG_ID}"

explorer_service "${SHELL_ID}"
explorer_service "${ZIG_ID}"
