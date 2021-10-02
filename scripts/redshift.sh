#!/bin/bash

[ $(which glxinfo | wc -l) -eq 0 ] && exit 1
[ $(glxinfo | grep -E -i "Device" | wc -l) -eq 0 ] && exit 1
[ $(which redshift | wc -l) -eq 0 ] && exit 1

redshift -x > /dev/null
redshift -O 5500k > /dev/null
