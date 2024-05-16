#! /bin/sh
# shellcheck disable=2034,2154
# SC2034: VAR appears unused => VAR used for templating
# SC2154: VAR is referenced but not assigned => VAR is assigned with eval statement in 01init.sh function

extern_img "${ALPINE_ID}" 'docker.io' "${ALPINE_ID}" "${ALPINE_TAG}"
extern_img "${BASH_ID}" 'docker.io' "${BASH_ID}" "${BASH_TAG}"
extern_img "${DOCKER_ID}" 'docker.io' "${DOCKER_ID}" "${DOCKER_TAG}"
extern_img "${LINUXSERVER_PROXY_ID}" 'lscr.io/linuxserver' 'socket-proxy' "${LINUXSERVER_PROXY_TAG}"
OS_IMG="${ALPINE_IMG}"
OS_LOCAL_IMG="${ALPINE_LOCAL_IMG}"

intern_img "${COLLECTOR_ID}" "${COLLECTOR_TAG}"
intern_img "${CONTROLLER_ID}" "${CONTROLLER_TAG}"
intern_img "${JUMPER_ID}" "${JUMPER_TAG}"
intern_img "${PROXY_ID}" "${PROXY_TAG}"

component_img "${BASH_ID}" "${BASH_COMPONENT_TAG}"
component_img "${DOCKER_ID}" "${DOCKER_COMPONENT_TAG}"
component_img "${ENTRYPOINT_ID}" "${ENTRYPOINT_COMPONENT_TAG}"
component_img "${GIT_ID}" "${GIT_COMPONENT_TAG}"
component_img "${LINGUIST_ID}" "${LINGUIST_COMPONENT_TAG}"
component_img "${MAN_ID}" "${MAN_COMPONENT_TAG}"
component_img "${PASS_ID}" "${PASS_COMPONENT_TAG}"
component_img "${SHELL_ID}" "${SHELL_COMPONENT_TAG}"
component_img "${SSHD_ID}" "${SSHD_COMPONENT_TAG}"
component_img "${TMUX_ID}" "${TMUX_COMPONENT_TAG}"
component_img "${VIM_ID}" "${VIM_COMPONENT_TAG}"
component_img "${WORKSPACES_ID}" "${WORKSPACES_COMPONENT_TAG}"
component_img "${ZIG_ID}" "${ZIG_COMPONENT_TAG}"
