#!/bin/sh

set -e
set -a
. ./.env
eval "printf \"$(cat ./compose.yaml.in)\"" > ./compose.yaml
unset $(set | grep ^DOCKER | cut -d'=' -f1)
docker compose down || :
docker volume rm "${COLLECTOR_ETC_CRONTABS_VOLUME}" \
                 "${COLLECTOR_OPT_DATA_VOLUME}" \
                 "${COLLECTOR_OPT_SCRIPTS_VOLUME}" \
                 "${COLLECTOR_VAR_LOG_VOLUME}" \
                 "${PROXY_FS_VOLUME}" \
                 "${SSH_VOLUME}" \
                 || :
docker compose --file ./components/compose.yaml --env-file ./.env build
docker compose build
docker compose create
docker compose start
docker volume prune --all --force
docker logs proxy 2> /dev/null | sed -n '/^-----/,/^-----/p'
docker image prune --all --force > /dev/null
docker attach jumper
