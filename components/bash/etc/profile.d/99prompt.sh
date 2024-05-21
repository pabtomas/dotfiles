theme ()
{
  printf '\[\033[01;38;5;%dm\]%s\[\033[m\]' "${PROMPT_THEME}" "${1}"
}

red ()
{
  printf '\[\033[01;31m\]%s\[\033[m\]' "${1}"
}

blue ()
{
  printf '\[\033[01;34m\]%s\[\033[m\]' "${1}"
}

ps1 ()
{
  local git_branch hostname path opened_brace opened_paren closed_brace closed_paren code

  if command -v git > /dev/null 2>&1
  then
    if git rev-parse --quiet --git-dir > /dev/null 2>&1
    then
      git_branch="$(theme "$(git rev-parse --abbrev-ref HEAD)")"
    fi
  fi

  opened_brace='['
  closed_brace=']'
  opened_paren='('
  closed_paren=')'

  if [[ "${1}" != '0' ]]
  then
    opened_brace="$(red "${opened_brace}")"
    closed_brace="$(red "${closed_brace}")"
    opened_paren="$(red "${opened_paren}")"
    closed_paren="$(red "${closed_paren}")"
    code="${1}"
  fi

  hostname="$(theme "$(hostname)")"
  path="$(blue '\w')"

  printf '%s%s%s%s%s%s%s%s%s%s$ ' "${opened_brace}" "${hostname}" "${closed_brace}" \
    "${path}" \
    "${git_branch:+"${opened_paren}"}" "${git_branch:-}" "${git_branch:+"${closed_paren}"}" \
    "${code:+"${opened_brace}"}" "${code:-}" "${code:+"${closed_brace}"}"
}

prompt_command ()
{
  set -- "${?}"
  PS1="$(ps1 "${1}")"
  export PS1
}

main ()
{
  PROMPT_COMMAND=prompt_command
  export PROMPT_COMMAND
}

main
