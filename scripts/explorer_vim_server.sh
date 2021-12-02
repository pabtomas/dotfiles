#!/bin/bash

if [ "x${1}" = "x" ]; then
  echo "explorer_vim_server.sh script needs one argument" >&2
  exit 1
else
  vim -c "StartServerExplorer ${1}"
fi
