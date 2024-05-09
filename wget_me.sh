#!/bin/sh

source_env ()
(
  set -a
  . ./.env
  eval "${1}"
)

set -eux
source_env '
  for template in $(find . -type f -name compose.yaml.in)
  do
    eval "printf \"$(cat "${template}")\n\"" > "${template%.*}"
  done'
docker compose down || :
(
  . ./.env
  unset $(set | grep ^DOCKER | cut -d'=' -f1)
  docker volume rm "${COLLECTOR_ETC_CRONTABS_VOLUME}" \
                   "${COLLECTOR_OPT_DATA_VOLUME}" \
                   "${COLLECTOR_OPT_SCRIPTS_VOLUME}" \
                   "${COLLECTOR_VAR_LOG_VOLUME}" \
                   "${PROXY_FS_VOLUME}" \
                   "${SSH_VOLUME}" \
                   || :
)
docker compose --file ./components/compose.yaml build
docker compose build
docker compose create
docker compose start
docker volume prune --all --force
docker logs "${PROXY_ID}" 2> /dev/null | sed -n '/^-----/,/^-----/p'
docker image prune --all --force > /dev/null
docker attach jumper
