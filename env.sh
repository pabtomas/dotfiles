#!/bin/sh

main ()
{
  if [ -d ./env.d ]
  then
    local file
    for file in ./env.d/*.sh
    do
      if [ -r "\${file}" ]
      then
        . "\${file}"
      fi
    done
  fi
}

main
