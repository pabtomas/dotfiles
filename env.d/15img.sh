#! /bin/sh
# shellcheck disable=2034,2154
# SC2034: VAR appears unused => VAR used for templating
# SC2154: VAR is referenced but not assigned => VAR is assigned with eval statement in 01init.sh function

_extern_img "${ALPINE_ID}" 'docker.io' "${ALPINE_ID}" "${ALPINE_TAG}"
_extern_img "${BASH_ID}" 'docker.io' "${BASH_ID}" "${BASH_TAG}"
_extern_img "${_BUILDKIT_ID}" 'docker.io/moby' "${_BUILDKIT_ID}" "${_BUILDKIT_TAG}"
_extern_img "${_DOCKER_ID}" 'docker.io' "${_DOCKER_ID}" "${_DOCKER_TAG}"
_extern_img "${LINUXSERVER_PROXY_ID}" 'lscr.io/linuxserver' 'socket-proxy' "${LINUXSERVER_PROXY_TAG}"
OS_IMG="${ALPINE_IMG}"
OS_LOCAL_IMG="${ALPINE_LOCAL_IMG}"

_intern_img "${BUILDER_ID}" "${OWNER_TAG}"
_intern_img "${COLLECTOR_ID}" "${OWNER_TAG}"
_intern_img "${CONTROLLER_ID}" "${OWNER_TAG}"
_intern_img "${JUMPER_ID}" "${OWNER_TAG}"
_intern_img "${PROXY_ID}" "${OWNER_TAG}"
_intern_img "${XSERVER_ID}" "${OWNER_TAG}"

_component_img "${BASH_ID}" "${OWNER_TAG}"
_component_img "${_DOCKER_ID}" "${OWNER_TAG}"
_component_img "${ENTRYPOINT_ID}" "${OWNER_TAG}"
_component_img "${GIT_ID}" "${OWNER_TAG}"
_component_img "${LINGUIST_ID}" "${OWNER_TAG}"
_component_img "${MAN_ID}" "${OWNER_TAG}"
_component_img "${NGINX_ID}" "${OWNER_TAG}"
_component_img "${PASS_ID}" "${OWNER_TAG}"
_component_img "${PROXY_ID}" "${OWNER_TAG}"
_component_img "${SHELL_ID}" "${OWNER_TAG}"
_component_img "${SSHD_ID}" "${OWNER_TAG}"
_component_img "${TMUX_ID}" "${OWNER_TAG}"
_component_img "${VIM_ID}" "${OWNER_TAG}"
_component_img "${WORKSPACES_ID}" "${OWNER_TAG}"
_component_img "${ZIG_ID}" "${OWNER_TAG}"

_runner_img "${SPACEPORN_ID}" "${OWNER_TAG}"
