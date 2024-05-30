#! /bin/sh
# shellcheck disable=2034,2154
# SC2034: VAR appears unused => VAR used for templating
# SC2154: VAR is referenced but not assigned => VAR is assigned with eval statement in 01init.sh function

_tag "${ALPINE_ID}" '3.20'
_tag 'os' "${ALPINE_TAG}"
_tag "${BASH_ID}" "5.2-${OS_ID}${OS_TAG}"
_tag "${_BUILDKIT_ID}" 'buildx-stable-1-rootless'
_tag "${_DOCKER_ID}" 'cli'
_tag "${LINUXSERVER_PROXY_ID}" 'latest'
_tag "${REGISTRY_ID}" '2'
_tag 'owner' 'latest'

_component_tag "${ZIG_ID}" '0.12.0'
