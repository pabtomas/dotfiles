#! /bin/sh
# shellcheck disable=2034,2154
# SC2034: VAR appears unused => VAR used for templating
# SC2154: VAR is referenced but not assigned => VAR is assigned with eval statement in 01init.sh function

_service "${BASH_ID}"
_service "${COLLECTOR_ID}"
_service "${CONTROLLER_ID}"
_service "${DOCKER_ID}"
_service "${EDITOR_ID}"
_service "${ENTRYPOINT_ID}"
_service "${GIT_ID}"
_service "${JUMPER_ID}"
_service "${LINGUIST_ID}"
_service "${MAN_ID}"
_service "${PASS_ID}"
_service "${PROXY_ID}"
_service "${SAFEDEPOSIT_ID}"
_service "${SCHOLAR_ID}"
_service "${SHELL_ID}"
_service "${SPACEPORN_ID}"
_service "${SSHD_ID}"
_service "${TMUX_ID}"
_service "${VIM_ID}"
_service "${WORKSPACES_ID}"
_service "${ZIG_ID}"

_explorer_service "${SHELL_ID}"
_explorer_service "${ZIG_ID}"
