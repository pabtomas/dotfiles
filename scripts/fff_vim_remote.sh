#!/bin/bash

if [ "x${1}" = "x" ]; then
  echo "fff_vim_remote.sh script needs one argument" >&2
  exit 1
else
  env VISUAL='/opt/scripts/fff_edit.sh' VIM_PLUG_SERVER=${1} fff
fi
