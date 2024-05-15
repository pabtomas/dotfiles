#!/bin/sh

main ()
{
  local env_d
  env_d="${1}/env.d"
  readonly env_d

  if [ -d "${env_d}" ]
  then
    local file
    for file in "${env_d}"/*.sh
    do
      if [ -r "${file}" ]
      then
        . "${file}"
      fi
    done
  fi
}

main ${@}
