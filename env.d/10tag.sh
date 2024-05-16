#! /bin/sh
# shellcheck disable=2034,2154
# SC2034: VAR appears unused => VAR used for templating
# SC2154: VAR is referenced but not assigned => VAR is assigned with eval statement in 01init.sh function

tag "${ALPINE_ID}" '3.19'
tag "${BASH_ID}" '5.2'
tag "${COLLECTOR_ID}" 'latest'
tag "${CONTROLLER_ID}" 'latest'
tag "${DOCKER_ID}" 'dind'
tag "${JUMPER_ID}" 'latest'
tag "${LINUXSERVER_PROXY_ID}" 'latest'
tag "${PROXY_ID}" 'latest'

component_tag "${BASH_ID}" 'latest'
component_tag "${DOCKER_ID}" 'latest'
component_tag "${ENTRYPOINT_ID}" 'latest'
component_tag "${GIT_ID}" 'latest'
component_tag "${LINGUIST_ID}" 'latest'
component_tag "${MAN_ID}" 'latest'
component_tag "${PASS_ID}" 'latest'
component_tag "${SHELL_ID}" 'latest'
component_tag "${SSHD_ID}" 'latest'
component_tag "${TMUX_ID}" 'latest'
component_tag "${VIM_ID}" 'latest'
component_tag "${WORKSPACES_ID}" 'latest'
component_tag "${ZIG_ID}" '0.12.0'
