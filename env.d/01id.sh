#! /bin/sh
# shellcheck disable=2034,2154
# SC2034: VAR appears unused => VAR used for templating
# SC2154: VAR is referenced but not assigned => VAR is assigned with eval statement in 01init.sh function

upper_id 'alpine'
upper_id 'bash'
upper_id 'collector'
upper_id 'component'
upper_id 'controller'
upper_id 'docker'
upper_id 'editor'
upper_id 'entrypoint'
upper_id 'explorer'
upper_id 'git'
upper_id 'jumper'
upper_id 'linguist'
upper_id 'linuxserver_proxy'
upper_id 'man'
upper_id 'pass'
upper_id 'proxy'
upper_id 'safedeposit'
upper_id 'scholar'
upper_id 'shell'
upper_id 'spaceporn'
upper_id 'sshd'
upper_id 'tmux'
upper_id 'vim'
upper_id 'workspaces'
upper_id 'zig'

OS="${ALPINE_ID}"

id 'OWNER' 'tiawl'

component_id "${BASH_ID}"
component_id "${DOCKER_ID}"
component_id "${ENTRYPOINT_ID}"
component_id "${GIT_ID}"
component_id "${LINGUIST_ID}"
component_id "${MAN_ID}"
component_id "${PASS_ID}"
component_id "${SHELL_ID}"
component_id "${SSHD_ID}"
component_id "${TMUX_ID}"
component_id "${VIM_ID}"
component_id "${WORKSPACES_ID}"
component_id "${ZIG_ID}"

explorer_id "${SHELL_ID}"
explorer_id "${ZIG_ID}"
