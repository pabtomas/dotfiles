#! /bin/sh

main ()
{
  set -- "${1}"/env.d/*.sh

  if [ -d "${1}" ]
  then
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
