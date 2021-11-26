#!/bin/bash

if [ "x${1}" = "x" ]; then
  echo "explorer_vim_remote.sh script needs one argument" >&2
  exit 1
else
  mktemp | xargs -o -I {} vim -c "StartRemoteExplorer ${1}" {}
fi
