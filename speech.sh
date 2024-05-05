#! /usr/bin/env bash

set -e
docker compose down || :
docker volume rm shared-ssh || :
docker compose -f ./components/compose.yaml --env-file ./.env build
docker compose build
docker compose create
docker compose start
docker image prune --all -f
docker attach jumper
