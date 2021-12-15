#!/usr/bin/env bash

if [[ "x${1}" = "x" ]]; then
  echo "fff_edit needs one argument" >&2
  exit 1
else
  vim --remote-expr 'FFFedit("'$(realpath ${1})'")' \
    --servername "VIM-${VIM_PLUG_SERVER}"
fi
