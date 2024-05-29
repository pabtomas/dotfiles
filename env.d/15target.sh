#! /bin/sh
# shellcheck disable=2034,2154
# SC2034: VAR appears unused => VAR used for templating
# SC2154: VAR is referenced but not assigned => VAR is assigned with eval statement in 01init.sh function

PROXY_PORT='2363'
BUILDER_PORT='2364'
XSERVER_PORT='2365'
REGISTRY_PORT='5000'

# shellcheck disable=2153
# SC2153: Possible misspelling => it is not, we really want PROXY_ID here
_DOCKER_TARGET="${PROXY_HOST}:${PROXY_PORT}"
HTTP_DOCKER_TARGET="http://${_DOCKER_TARGET}"
TCP_DOCKER_TARGET="tcp://${_DOCKER_TARGET}"

# shellcheck disable=2153
# SC2153: Possible misspelling => it is not, we really want PROXY_ID here
REGISTRY_TARGET="${REGISTRY_HOST}:${REGISTRY_PORT}"

# shellcheck disable=2153
# SC2153: Possible misspelling => it is not, we really want BUILDER_HOST here
_BUILDKIT_TARGET="${BUILDER_HOST}:${BUILDER_PORT}"
TCP_BUILDKIT_TARGET="tcp://${_BUILDKIT_TARGET}"
