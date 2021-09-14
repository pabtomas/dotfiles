#!/bin/bash

unalias -a
alias ls='ls --color'
alias ll='ls -lA --color'
alias grep='grep --color'

function cd () {

  command cd "$@"

  if [ $? -eq 0 ]; then

    command timeout 0.1 bash -c \
\ \ \ 'SZ=0;'\
\ \ \ 'DSZ=$(( (('${LINES}' / 2) * ('${COLUMNS}' / ((('\
\ \ \ '  $(command ls -AUl'\
\ \ \ '    | command awk "{printf \"%s %s %s\n\", \$9, \$10, \$11}"'\
\ \ \ '    | command wc -L) / 8) + 1) * 8))) + 1 ));'\
\ \ \ 'SZ=$(command ls -AU'\
\ \ \ '     | (while command read -r file && [ ${SZ} -lt ${DSZ} ]; do'\
\ \ \ '          ((SZ+=1));'\
\ \ \ '        done; command echo ${SZ}));'\
\ \ \ 'NC="\033[0m";'\
\ \ \ 'if [ ${SZ} -eq 0 ]; then'\
\ \ \ '  COL="\033[1;36m";'\
\ \ \ '  command echo -e ${COL}"Empty directory."${NC};'\
\ \ \ 'elif [ ${SZ} -lt ${DSZ} ]; then'\
\ \ \ '  command ls -lA --color | command tail -n+2'\
\ \ \ '    | command awk "{printf \"%s %s %s\n\", \$9, \$10, \$11}"'\
\ \ \ '    | command column;'\
\ \ \ 'else'\
\ \ \ '  COL="\033[1;33m";'\
\ \ \ '  command echo -e ${COL}"Huge current directory."'\
\ \ \ '    "Use listing commands carrefully."${NC};'\
\ \ \ 'fi'

    if [ $? -eq 124 ]; then
      local COL="\033[1;31m"
      local NC="\033[0m"
      command echo -e ${COL}"Timeout occured."\
        "Avoid listing commands in current directory."${NC}
    fi

  fi
}

# change directories easily
for I in $(seq 2 1 10); do
  ALIAS=$(printf '.%.0s' $(seq 1 ${I}))
  DIR=$(printf '../%.0s' $(seq 1 $(( ${I} - 1 ))))
  alias "${ALIAS}"='cd '${DIR}
done

function mkdir () {
  command mkdir -pv "$@"
  [ $? -eq 0 ] \
    && command echo -n "mkdir: change directory for '$(realpath $@)' ? " \
    && command read Y && [[ ${Y,,} == 'y' ]] && cd "$@"
}

alias vi='vim'
alias rm='rm -iv'
alias cp='cp -iv'
alias mv='mv -iv'
alias hs='history | grep -i'
alias f?='find . | grep -E'
alias ps?='ps -ax | grep -E'
alias sudo='sudo '
alias update='sudo apt-get update && sudo apt-get upgrade '\
\ '&& sudo apt-get autoremove && sudo apt-get autoclean'

function extract () {

  if [[ "$#" -lt 1 ]]; then
    command echo "Usage: extract <path/file_name>"\
      ".<zip|rar|bz2|gz|tar|tbz2|tgz|Z|7z|xz|ex|tar.bz2|tar.gz|tar.xz>"
    return 1 #not enough args
  fi

  if [[ ! -e "$1" ]]; then
    command echo -e "File does not exist!"
    return 2 # File not found
  fi

  local DESTDIR="."

  local FILE=$(command basename "$1")

  case "${FILE##*.}" in
    tar)
      command echo -e "Extracting $1 to $DESTDIR: (uncompressed tar)"
      command tar xvf "$1" -C "$DESTDIR"
      ;;
    gz)
      command echo -e "Extracting $1 to $DESTDIR: (gip compressed tar)"
      command tar xvfz "$1" -C "$DESTDIR"
    ;;
    tgz)
      command echo -e "Extracting $1 to $DESTDIR: (gip compressed tar)"
      command tar xvfz "$1" -C "$DESTDIR"
      ;;
    xz)
      command echo -e "Extracting  $1 to $DESTDIR: (gip compressed tar)"
      command tar xvf -J "$1" -C "$DESTDIR"
      ;;
    bz2)
      command echo -e "Extracting $1 to $DESTDIR: (bzip compressed tar)"
      command tar xvfj "$1" -C "$DESTDIR"
      ;;
    tbz2)
      command echo -e "Extracting $1 to $DESTDIR: (tbz2 compressed tar)"
      command tar xvjf "$1" -C "$DESTDIR"
      ;;
    zip)
      command echo -e "Extracting $1 to $DESTDIR: (zip compressed file)"
      command unzip "$1" -d "$DESTDIR"
      ;;
    lzma)
      command echo -e "Extracting $1 : (lzma compressed file)"
      command unlzma "$1"
      ;;
    rar)
      command echo -e "Extracting $1 to $DESTDIR: (rar compressed file)"
      command unrar x "$1" "$DESTDIR"
      ;;
    7z)
      command echo -e  "Extracting $1 to $DESTDIR: (7zip compressed file)"
      command 7za e "$1" -o "$DESTDIR"
      ;;
    xz)
      command echo -e  "Extracting $1 : (xz compressed file)"
      command unxz  "$1"
      ;;
    exe)
      command cabextract "$1"
      ;;
    *)
      command echo -e "Unknown format!"
      return
      ;;
  esac
}

alias ga='git add'
alias gam='git add -A && git commit -m'
alias gb='git branch'
alias gc='git clone'
alias gd='git diff --color-words | less -r'
alias gh='git checkout'
alias gl="git log --graph --color --abbrev-commit --date=relative "\
\ "--pretty=format:'%Cred%h%Creset %C(cyan)%an%Creset: %s\
%C(yellow)%d%Creset (%cr)' | sed 's/\((.\+\) et\(.\+)\)$/\1,\2/g' \
 | sed 's/\((.\+\) ans\?\(.*)\)$/\1Y\2/g' \
 | sed 's/\((.\+\) mois\(.*)\)$/\1M\2/g' \
 | sed 's/\((.\+\) semaines\?\(.*)\)$/\1W\2/g' \
 | sed 's/\((.\+\) jours\?\(.*)\)$/\1d\2/g' \
 | sed 's/\((.\+\) heures\?\(.*)\)$/\1h\2/g' \
 | sed 's/\((.\+\) minutes\?\(.*)\)$/\1m\2/g' \
 | sed 's/\((.\+\) secondes\?\(.*)\)$/\1s\2/g' \
 | sed 's/(il y a \(.\+\))$/"$(tput setaf 2)"(\1)"$(tput sgr0)"/' | less -r"
alias gm='git commit -m'
alias gp='git pull'
alias gP='git push'
alias gr='git remote'
alias gs='git status -s'
alias gS='git ls-files | xargs -n1 git blame --line-porcelain '\
\ "| sed -n 's/^author //p' | sort -f | uniq -ic | sort -nr"

function gu () {
  if [ $(git diff --cached --name-only | wc -l) -gt 0 ]; then
    git reset --mixed
  elif [ $(git log --pretty=oneline origin/master..master | wc -l) -gt 0 ] \
    && [ $(git status -s | wc -l) -eq 0 ]; then
      git reset --soft HEAD^
  fi
}

function gamP () {
  git add -A && git commit -m "$@" && git pull && git push
}
