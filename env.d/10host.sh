#! /bin/sh
# shellcheck disable=2034,2154
# SC2034: VAR appears unused => VAR used for templating
# SC2154: VAR is referenced but not assigned => VAR is assigned with eval statement in 01init.sh function

_host "${BRIDGE_ID}"
_host "${BUILDER_ID}"
_host "${COLLECTOR_ID}"
_host "${CONTROLLER_ID}"
_host "${EDITOR_ID}"
_host "${JUMPER_ID}"
_host "${MAN_ID}"
_host "${PROXY_ID}"
_host "${SAFEDEPOSIT_ID}"
_host "${SCHOLAR_ID}"
_host "${XSERVER_ID}"

_explorer_host "${SHELL_ID}"
_explorer_host "${ZIG_ID}"

_runner_host "${SPACEPORN_ID}"
