#! /bin/sh
# shellcheck disable=2034,2154
# SC2034: VAR appears unused => VAR used for templating
# SC2154: VAR is referenced but not assigned => VAR is assigned with eval statement in 01init.sh function

_extern_img "${ALPINE_ID}" 'docker.io' 'library' "${ALPINE_ID}" "${ALPINE_TAG}"
_extern_img "${BASH_ID}" 'docker.io' 'library' "${BASH_ID}" "${BASH_TAG}"
_extern_img "${_BUILDKIT_ID}" 'docker.io' 'moby' "${_BUILDKIT_ID}" "${_BUILDKIT_TAG}"
_extern_img "${_DOCKER_ID}" 'docker.io' 'library' "${_DOCKER_ID}" "${_DOCKER_TAG}"
_extern_img "${LINUXSERVER_PROXY_ID}" 'lscr.io' 'linuxserver' 'socket-proxy' "${LINUXSERVER_PROXY_TAG}"
_extern_img "${REGISTRY_ID}" 'docker.io' 'library' "${REGISTRY_ID}" "${REGISTRY_TAG}"
OS_IMG="${ALPINE_IMG}"
OS_LOCAL_IMG="${ALPINE_LOCAL_IMG}"

_intern_img "${BUILDER_ID}" "${OWNER_TAG}"
_intern_img "${CONTROLLER_ID}" "${OWNER_TAG}"
_intern_img "${JUMPER_ID}" "${OWNER_TAG}"
_intern_img "${LISTENER_ID}" "${OWNER_TAG}"
_intern_img "${PROXY_ID}" "${OWNER_TAG}"
_intern_img "${XSERVER_ID}" "${OWNER_TAG}"

_layer_img "${BASH_ID}" "${OWNER_TAG}"
_layer_img "${BASH_ENTRYPOINT_ID}" "${OWNER_TAG}"
_layer_img "${_DOCKER_ID}" "${OWNER_TAG}"
_layer_img "${ENTRYPOINT_ID}" "${OWNER_TAG}"
_layer_img "${EXPLORER_ID}" "${OWNER_TAG}"
_layer_img "${GIT_ID}" "${OWNER_TAG}"
_layer_img "${HTTP_ID}" "${OWNER_TAG}"
_layer_img "${LINGUIST_ID}" "${OWNER_TAG}"
_layer_img "${MAN_ID}" "${OWNER_TAG}"
_layer_img "${NGINX_ID}" "${OWNER_TAG}"
_layer_img "${PASS_ID}" "${OWNER_TAG}"
_layer_img "${SHELL_ID}" "${OWNER_TAG}"
_layer_img "${SOCAT_ID}" "${OWNER_TAG}"
_layer_img "${SSHD_ID}" "${OWNER_TAG}"
_layer_img "${TMUX_ID}" "${OWNER_TAG}"
_layer_img "${VIM_ID}" "${OWNER_TAG}"
_layer_img "${WORKSPACES_ID}" "${OWNER_TAG}"
_layer_img "${ZIG_ID}" "${OWNER_TAG}"

_relay_img "${SPACEPORN_ID}" "${OWNER_TAG}"
_runner_img "${SPACEPORN_ID}" "${OWNER_TAG}"
