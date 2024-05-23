#! /bin/sh
# shellcheck disable=2034,2154
# SC2034: VAR appears unused => VAR used for templating
# SC2154: VAR is referenced but not assigned => VAR is assigned with eval statement in 01init.sh function

_tag "${ALPINE_ID}" '3.20'
_tag 'os' "${ALPINE_TAG}"
_tag "${BASH_ID}" "5.2-${OS}${OS_TAG}"
_tag "${_BUILDKIT_ID}" 'buildx-stable-1-rootless'
_tag "${_DOCKER_ID}" 'cli'
_tag "${COLLECTOR_ID}" 'latest'
_tag "${CONTROLLER_ID}" 'latest'
_tag "${JUMPER_ID}" 'latest'
_tag "${LINUXSERVER_PROXY_ID}" 'latest'
_tag "${PROXY_ID}" 'latest'

_component_tag "${BASH_ID}" 'latest'
_component_tag "${_DOCKER_ID}" 'latest'
_component_tag "${ENTRYPOINT_ID}" 'latest'
_component_tag "${GIT_ID}" 'latest'
_component_tag "${LINGUIST_ID}" 'latest'
_component_tag "${MAN_ID}" 'latest'
_component_tag "${PASS_ID}" 'latest'
_component_tag "${SHELL_ID}" 'latest'
_component_tag "${SSHD_ID}" 'latest'
_component_tag "${TMUX_ID}" 'latest'
_component_tag "${VIM_ID}" 'latest'
_component_tag "${WORKSPACES_ID}" 'latest'
_component_tag "${ZIG_ID}" '0.12.0'

_runner_tag "${SPACEPORN_ID}" 'latest'
