#! /usr/bin/env bash

set -e
source ./.env
docker compose down || :
docker volume rm "${SSH_VOLUME}" || :
docker compose -f ./components/compose.yaml --env-file ./.env build
docker compose build
docker compose create
docker compose start
docker logs proxy 2> /dev/null
docker image prune --all -f > /dev/null
docker attach jumper
