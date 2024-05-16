#! /bin/sh
# shellcheck disable=2034,2154
# SC2034: VAR appears unused => VAR used for templating
# SC2154: VAR is referenced but not assigned => VAR is assigned with eval statement in 01init.sh function

host "${COLLECTOR_ID}"
host "${CONTROLLER_ID}"
host "${EDITOR_ID}"
host "${JUMPER_ID}"
host "${MAN_ID}"
host "${PROXY_ID}"
host "${SAFEDEPOSIT_ID}"
host "${SCHOLAR_ID}"

explorer_host "${SHELL_ID}"
explorer_host "${ZIG_ID}"
