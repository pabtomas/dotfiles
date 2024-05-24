#! /bin/sh
# shellcheck disable=2034,2154
# SC2034: VAR appears unused => VAR used for templating
# SC2154: VAR is referenced but not assigned => VAR is assigned with eval statement in 01init.sh function

_id 'alpine'
_id 'bash'
_id 'builder'
_id 'buildkit'
_id 'collector'
_id 'component'
_id 'controller'
_id 'docker'
_id 'editor'
_id 'entrypoint'
_id 'explorer'
_id 'git'
_id 'jumper'
_id 'linguist'
_id 'linuxserver_proxy'
_id 'local'
_id 'man'
_id 'nginx'
_id 'pass'
_id 'proxy'
_id 'runner'
_id 'safedeposit'
_id 'scholar'
_id 'shell'
_id 'spaceporn'
_id 'sshd'
_id 'tmux'
_id 'vim'
_id 'workspaces'
_id 'xserver'
_id 'zig'

__id 'os' "${ALPINE_ID}"
__id 'owner' 'tiawl'

_sfx "${COMPONENT_ID}${ID_SFX}"
_sfx "${EXPLORER_ID}${ID_SFX}"
_sfx "${RUNNER_ID}${ID_SFX}"
_sfx "${COMPONENT_ID}${IMG_SFX}"
_sfx "${LOCAL_ID}${IMG_SFX}"
_sfx "${RUNNER_ID}${IMG_SFX}"
_sfx "${EXPLORER_ID}${HOST_SFX}"
_sfx "${RUNNER_ID}${HOST_SFX}"
_sfx "${EXPLORER_ID}${SERVICE_SFX}"
_sfx "${COMPONENT_ID}${TAG_SFX}"

_component_id "${BASH_ID}"
_component_id "${_DOCKER_ID}"
_component_id "${ENTRYPOINT_ID}"
_component_id "${GIT_ID}"
_component_id "${LINGUIST_ID}"
_component_id "${MAN_ID}"
_component_id "${PASS_ID}"
_component_id "${SHELL_ID}"
_component_id "${SSHD_ID}"
_component_id "${TMUX_ID}"
_component_id "${VIM_ID}"
_component_id "${WORKSPACES_ID}"
_component_id "${ZIG_ID}"

_explorer_id "${SHELL_ID}"
_explorer_id "${ZIG_ID}"

_runner_id "${SPACEPORN_ID}"
