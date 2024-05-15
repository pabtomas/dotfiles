#!/bin/sh

main ()
{
  local env_d
  env_d="$(cd -- "$(dirname -- "${0}")" &> /dev/null && pwd)/env.d"
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

main
