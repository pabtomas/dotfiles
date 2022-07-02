#!/bin/sh

set -eu

OLD_IFS="${IFS}"
readonly OLD_IFS

o () {
  IFS='('
  set -f
  if [ ${#} -eq 1 ]
  then
    set +f -- ${@}
  else
    shift
    set -- ${@}
    IFS='*'
    set +f -- ${1}
    set -- "${1}\033[38;5;9m*${2}\033[m"
  fi
  printf '%b\n' "${1}"
  IFS="${OLD_IFS}"
}

# Sort snapshots chronologically and get older snapshot as arg 1

cd "$(mktemp -d)"

{
  git init
  : > "${1}"
  git add -A
  git commit -m "${1}"
  git branch -m "${1}"
  [ -s "/home/user/Workspace/Perso/test/tree/${1}/children" ] && set -f \
    && set +f -- $(cat "/home/user/Workspace/Perso/test/tree/${1}/children")

  while [ ${#} -gt 0 ]
  do
    [ -s "/home/user/Workspace/Perso/test/tree/${1}/parent" ] \
      && git checkout "$(cat "/home/user/Workspace/Perso/test/tree/${1}/parent")"
    [ -s "/home/user/Workspace/Perso/test/tree/${1}/children" ] && set -f \
      && set +f -- "${@}" $(cat "/home/user/Workspace/Perso/test/tree/${1}/children")
    git rev-parse --quiet --verify "${1}" || git branch "${1}"
    git checkout "${1}"
    : > "${1}"
    git add -A
    git commit -m "${1}"
    shift
  done

  git checkout "$(cat "/home/user/Workspace/Perso/test/tree/current")"
} > /dev/null 2>&1

IFS='
'

set -f
set +f -- $(git log --graph --all --pretty='%s %d' --no-color)
IFS="${OLD_IFS}"

while [ ${#} -gt 0 ]
do
  case "${1}" in
    *'(HEAD -> '*) o 'RED' "${1}" ;;
    *'*'*) o "${1}" ;;
    *) printf '%s\n' "${1}" ;;
  esac
  shift
done
