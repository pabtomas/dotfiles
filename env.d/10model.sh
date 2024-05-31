#! /bin/sh
# shellcheck disable=2034,2154
# SC2034: VAR appears unused => VAR used for templating
# SC2154: VAR is referenced but not assigned => VAR is assigned with eval statement in 01init.sh function

_model "${_BUILDKIT_ID}"
_model "${_DOCKER_ID}"
_model "${MAN_ID}"
_model "${PASS_ID}"
_model "${REGISTRY_ID}"
_model "${SHELL_ID}"
_model "${SSHD_ID}"
_model "${VIM_ID}"
_model "${ZIG_ID}"
