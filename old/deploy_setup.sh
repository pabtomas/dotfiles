#!/bin/sh

version_pass ()
{
  if [ -e "$(command -v pass)" ]
  then
    set -- "${IFS}"
    IFS="${setup_newline}"
    set -- "${1}" $(pass version)
    IFS="${1}"
    set -- "${5#"${5%%[[:digit:]]*}"}"
    set -- "${1%"${1##*[[:digit:]]}"}"
    printf 'pass %s' "${1}"
  else
    printf 'pass %s' "${setup_noversion}"
  fi
  return 0
}

main ()
{
  set -eu

  set -- "${1}" "${2}$(version_pass)${setup_sep}"

  # for password-store
  install xclip

  # for password-store and docker
  install gnupg

  setup_notag='true' git_install 'pass' 'https://git.zx2c4.com/password-store' \
    'Installing password-store' \
    "${_sudo} make install --directory ${setup_localsrc}/pass"
  return 0
}

main "${@}"
