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
TRASH_PATH="$(mktemp -d)"
export TRASH_PATH
for template in $(find . -type f -name compose.yaml.in)
do
  source_env "printf '%s\n' \"$(cat "${template}")\"" > "${template%.*}"
done
# TODO: manage this differently
# docker compose down --timeout 0 || :
# source_env_without_docker_host '
#   docker volume rm $(docker volume list --filter "name=${DELETE_ME_SFX}" --format "{{ .Name }}")' || :
docker network prune --force
docker compose --file ./components/compose.yaml build
docker compose build
docker compose create
docker compose start
docker volume prune --all --force
source_env_without_docker_host '
  docker logs "${PROXY_ID}" 2> /dev/null | sed -n "/^-----\+$/,/^-----\+$/p"'
#docker image prune --all --force > /dev/null
#docker attach jumper
rm -rf "${TRASH_PATH}"
