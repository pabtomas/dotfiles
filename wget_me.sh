#!/bin/sh

source_env ()
(
  set -a
  . ./env.sh
  eval "${1}"
)

source_env_without_docker_host ()
(
  . ./env.sh
  unset DOCKER_HOST
  eval "${1}"
)

set -eu
source_env '
  for template in $(find . -type f -name compose.yaml.in)
  do
    eval "printf \"$(cat "${template}")\n\"" > "${template%.*}"
  done'
docker compose down --timeout 0 || :
source_env_without_docker_host '
  docker volume rm "${COLLECTOR_ETC_CRONTABS_VOLUME}" \
                   "${COLLECTOR_OPT_DATA_VOLUME}" \
                   "${COLLECTOR_OPT_SCRIPTS_VOLUME}" \
                   "${COLLECTOR_VAR_LOG_VOLUME}" \
                   "${PROXY_FS_VOLUME}" \
                   "${SSH_VOLUME}" \
                   || :'
docker network prune --force
docker compose --file ./components/compose.yaml build
docker compose build
docker compose create
docker compose start
docker volume prune --all --force
source_env_without_docker_host '
  docker logs "${PROXY_ID}" 2> /dev/null | sed -n "/^-----/,/^-----/p"'
docker image prune --all --force > /dev/null
docker attach jumper
