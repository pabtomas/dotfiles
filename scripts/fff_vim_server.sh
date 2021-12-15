#!/usr/bin/env bash

if [[ "x${1}" = "x" ]]; then
  echo "fff_vim_server.sh script needs one argument" >&2
  exit 1
else
  vim -c "call StartServer('fff',${1})"
fi
