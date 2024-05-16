#!/bin/sh

main ()
{
  env_d="${1}/env.d"

  if [ -d "${env_d}" ]
  then
    for file in "${env_d}"/*.sh
    do
      if [ -r "${file}" ]
      then
        . "${file}"
      fi
    done
  fi
  unset file env_d
}

main ${@}
