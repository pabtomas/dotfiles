#! /bin/sh

main ()
{
  if [ -n "${DEBUG:-}" ]; then set -x; fi

  if [ -d "${1}" ]
  then
    set -- "${1}"/env.d/*.sh
    while [ "${#}" != '0' ]
    do
      if [ -r "${1}" ]
      then
        # shellcheck disable=1090
        # SC1090: ShellCheck can't follow non-constant source => specified in CLI
        . "${1}"
      fi
      shift
    done
  fi
}

main "${@}"
