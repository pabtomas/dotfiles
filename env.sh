#! /bin/sh

main ()
{
  if [ -d "${1}" ]
  then
    set -- "${1}"/env.d/*.sh
    while [ "${#}" != '0' ]
    do
      if [ -r "${1}" ]
      then
        . "${1}"
      fi
      shift
    done
  fi
}

main ${@}
