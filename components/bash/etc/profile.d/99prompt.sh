main ()
{
  PROMPT_COMMAND='
    if git rev-parse --quiet --git-dir > /dev/null 2>&1
    then
      GIT_BRANCH="(\[\033[01;38;5;93m\]$(git rev-parse --abbrev-ref HEAD)\[\033[m\])"
    else
      GIT_BRANCH=""
    fi
    HOSTNAME="$(hostname)"
    PS1="[\[\033[01;38;5;${PROMPT_THEME}m${HOSTNAME}\]\[\033[m]\]\[\033[01;34m\]\w\[\033[m\]${GIT_BRANCH}\$ "'

  export PROMPT_COMMAND
}

main
