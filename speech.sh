#! /usr/bin/env bash

docker compose down
docker volume rm shared-ssh
docker compose -f ./components/compose.yaml --env-file ./.env build
docker compose build
docker compose create
docker compose start
docker attach jumper
