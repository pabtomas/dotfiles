#! /bin/sh

ID 'bash'
ID 'collector'
ID 'component'
ID 'controller'
ID 'docker'
ID 'editor'
ID 'entrypoint'
ID 'explorer'
ID 'git'
ID 'jumper'
ID 'linguist'
ID 'linuxserver_proxy'
ID 'man'
ID 'pass'
ID 'proxy'
ID 'safedeposit'
ID 'scholar'
ID 'shell'
ID 'spaceporn'
ID 'sshd'
ID 'tmux'
ID 'vim'
ID 'workspaces'
ID 'zig'

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
