#! /bin/sh
# shellcheck disable=2034,2154
# SC2034: VAR appears unused => VAR used for templating
# SC2154: VAR is referenced but not assigned => VAR is assigned with eval statement in 01init.sh function

id 'alpine'
id 'bash'
id 'collector'
id 'component'
id 'controller'
id 'docker'
id 'editor'
id 'entrypoint'
id 'explorer'
id 'git'
id 'jumper'
id 'linguist'
id 'linuxserver_proxy'
id 'local'
id 'man'
id 'pass'
id 'proxy'
id 'safedeposit'
id 'scholar'
id 'shell'
id 'spaceporn'
id 'sshd'
id 'tmux'
id 'vim'
id 'workspaces'
id 'zig'

OS="${ALPINE_ID}"

_id 'owner' 'tiawl'

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
