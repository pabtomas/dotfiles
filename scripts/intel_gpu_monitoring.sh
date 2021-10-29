#!/bin/bash

[ $(which glxinfo | wc -l) -eq 0 ] && exit 1
[ $(glxinfo | grep -E -i "Device" | grep -E -i "Intel" | wc -l) -eq 0 ] \
  && exit 1
DIR="${HOME}/.cache/intel_gpu_monitoring"
command mkdir -p ${DIR}
sudo intel_gpu_top -J -s 500 \
  | sed --unbuffered -e 's/^{/'$(printf "\x1e")'{/' \
  | jq --seq --unbuffered '.engines."Render/3D/0".busy' 2> /dev/null \
  | sed --unbuffered -e 's/^'$(printf "\x1e")'//' \
  | unbuffer -p xargs -I {} printf "%.0f\n" {} \
  | unbuffer -p xargs -I [] touch ${DIR}/[]
