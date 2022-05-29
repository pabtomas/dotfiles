unalias -a

function mario() {
  vim -u /etc/vim/vimrc -N -c "execute \"Mario\" | tabonly | set nowrap | normal! G | echo \"Poisson d'avril ! Quitter = Q, Jouer = Haut, Gauche, Droite et mettre la police du terminal à 6"
}

function tbm () {
  while :; do
    D=$(date +"%A %d %B %Y %H:%M:%S")
    B1="$(curl https://ws.infotbm.com/ws/1.0/get-realtime-pass/3049/03 2> /dev/null | jq -r '.destinations[][] | "\(.waittime_text) \(.destination_name) \(.arrival_theorique)"')"
    B1b="$(echo "${B1}" | grep -E "heure" | sort -n | uniq | sed -e "s/\([[:alpha:]]\)\([[:alpha:]]*\)/\1\L\2/g; s/:[[:digit:]]\{2\}$//; s/[[:digit:]]\{4,\}-[[:digit:]]\{2\}-[[:digit:]]\{2\} //")"
    [[ ${#B1b} -gt 0 ]] && B1b="${B1b}\n"
    B1="$(echo "${B1}" | grep -vE "heure" | sort -n | uniq | sed -e "s/\([[:alpha:]]\)\([[:alpha:]]*\)/\1\L\2/g; s/:[[:digit:]]\{2\}$//; s/[[:digit:]]\{4,\}-[[:digit:]]\{2\}-[[:digit:]]\{2\} //")"
    B2="$(curl https://ws.infotbm.com/ws/1.0/get-realtime-pass/112/71 2> /dev/null | jq -r '.destinations[][] | "\(.waittime_text) \(.destination_name) \(.arrival_theorique)"')"
    B2b="$(echo "${B2}" | grep -E "heure" | sort -n | uniq | sed -e "s/\([[:alpha:]]\)\([[:alpha:]]*\)/\1\L\2/g; s/:[[:digit:]]\{2\}$//; s/[[:digit:]]\{4,\}-[[:digit:]]\{2\}-[[:digit:]]\{2\} //")"
    [[ ${#B2b} -gt 0 ]] && B2b="${B2b}\n"
    B2="$(echo "${B2}" | grep -vE "heure" | sort -n | uniq | sed -e "s/\([[:alpha:]]\)\([[:alpha:]]*\)/\1\L\2/g; s/:[[:digit:]]\{2\}$//; s/[[:digit:]]\{4,\}-[[:digit:]]\{2\}-[[:digit:]]\{2\} //")"
    T1="$(curl https://ws.infotbm.com/ws/1.0/get-realtime-pass/3696/A 2> /dev/null | jq -r '.destinations[][] | "\(.waittime_text) \(.destination_name) \(.arrival_theorique)"')"
    T1b="$(echo "${T1}" | grep -E "heure" | sort -n | uniq | sed -e "s/\([[:alpha:]]\)\([[:alpha:]]*\)/\1\L\2/g; s/:[[:digit:]]\{2\}$//; s/[[:digit:]]\{4,\}-[[:digit:]]\{2\}-[[:digit:]]\{2\} //")"
    [[ ${#T1b} -gt 0 ]] && T1b="${T1b}\n"
    T1="$(echo "${T1}" | grep -vE "heure" | sort -n | uniq | sed -e "s/\([[:alpha:]]\)\([[:alpha:]]*\)/\1\L\2/g; s/:[[:digit:]]\{2\}$//; s/[[:digit:]]\{4,\}-[[:digit:]]\{2\}-[[:digit:]]\{2\} //")"
    T2="$(curl https://ws.infotbm.com/ws/1.0/get-realtime-pass/3715/A 2> /dev/null | jq -r '.destinations[][] | "\(.waittime_text) \(.destination_name) \(.arrival_theorique)"')"
    T2b="$(echo "${T2}" | grep -E "heure" | sort -n | uniq | sed -e "s/\([[:alpha:]]\)\([[:alpha:]]*\)/\1\L\2/g; s/:[[:digit:]]\{2\}$//; s/[[:digit:]]\{4,\}-[[:digit:]]\{2\}-[[:digit:]]\{2\} //")"
    [[ ${#T2b} -gt 0 ]] && T2b="${T2b}\n"
    T2="$(echo "${T2}" | grep -vE "heure" | sort -n | uniq | sed -e "s/\([[:alpha:]]\)\([[:alpha:]]*\)/\1\L\2/g; s/:[[:digit:]]\{2\}$//; s/[[:digit:]]\{4,\}-[[:digit:]]\{2\}-[[:digit:]]\{2\} //")"
    clear
    printf "${D}\n\n🚍 \033[1;37;1;44m 3 \033[0m Collège Hastignan\n${B1}\n${B1b}\n🚍 \033[1;37;1;42m 71 \033[0m Cerema\n${B2}\n${B2b}\n🚇 \033[1;37m\033[1;48;5;198m A \033[0m Palmer\n${T1}\n${T1b}\n🚇 \033[1;37m\033[1;48;5;198m A \033[0m Place Du Palais\n${T2}\n${T2b}\nPress Q to quit"
    read -s -n 1 -t 1 INPUT <&1
    [[ ${INPUT} == "q" ]] && break
  done
  clear
}

function colors () {
  curl -s https://gist.githubusercontent.com/HaleTom/89ffe32783f89f403bba96bd7bcd1263/raw/ | bash
}

alias ls='ls --color'
alias grep='grep --color'
alias diff='diff -u --color'
alias ag='ag -t --hidden --color --multiline --numbers --pager "less -R"'
alias agi='ag --hidden --color --multiline --numbers --pager "less -R" --ignore'
alias tree='tree -C'
alias watch='watch -c -n 1'
alias ps='ps -a -x'
alias rm='rm -i -r -v'
alias cp='cp -i -r -v'
alias mv='mv -i -n -v'
alias ln='ln -v'
alias readlink='readlink -f'
alias mkdir='mkdir -p -v'
alias sudo='sudo '
alias cal='ncal -w -b -M'
alias vi='vim'
alias ip='hostname -I'
alias less='less -R'

set 1 2 3 4
while [ "${*}" ]
do
  alias ."$(printf '.%0.s' "${@}")"='cd '"$(printf '../%0.s' "${@}")"
  shift
done

function extract () {

  if [[ "$#" -lt 1 ]]; then
    echo "Usage: extract <path/file_name>"\
      ".<zip|rar|bz2|gz|tar|tbz2|tgz|Z|7z|xz|ex|tar.bz2|tar.gz|tar.xz>"
    return 1 #not enough args
  fi

  if [[ ! -e "${1}" ]]; then
    echo -e "File does not exist!"
    return 2 # File not found
  fi

  local DESTDIR="${1}_extracted"
  if [[ -d "${DESTDIR}" ]]; then
    echo -e "${DESTDIR} already exists. Can't extract in a safe destination."
    return 3 # extracted dest already exists
  fi

  mkdir ${DESTDIR}

  local FILE=$(basename "${1}")

  case "${FILE##*.}" in
    tar)
      echo -e "Extracting ${1} to ${DESTDIR}: (uncompressed tar)"
      tar xvf "${1}" -C "${DESTDIR}"
      ;;
    gz)
      echo -e "Extracting ${1} to ${DESTDIR}: (gip compressed tar)"
      tar xvfz "${1}" -C "${DESTDIR}"
    ;;
    tgz)
      echo -e "Extracting ${1} to ${DESTDIR}: (gip compressed tar)"
      tar xvfz "${1}" -C "${DESTDIR}"
      ;;
    xz)
      echo -e "Extracting  ${1} to ${DESTDIR}: (gip compressed tar)"
      tar xvf -J "${1}" -C "${DESTDIR}"
      ;;
    bz2)
      echo -e "Extracting ${1} to ${DESTDIR}: (bzip compressed tar)"
      tar xvfj "${1}" -C "${DESTDIR}"
      ;;
    tbz2)
      echo -e "Extracting ${1} to ${DESTDIR}: (tbz2 compressed tar)"
      tar xvjf "${1}" -C "${DESTDIR}"
      ;;
    zip)
      echo -e "Extracting ${1} to ${DESTDIR}: (zip compressed file)"
      unzip "${1}" -d "${DESTDIR}"
      ;;
    lzma)
      echo -e "Extracting ${1} : (lzma compressed file)"
      unlzma "${1}"
      ;;
    rar)
      echo -e "Extracting ${1} to ${DESTDIR}: (rar compressed file)"
      unrar x "${1}" "${DESTDIR}"
      ;;
    7z)
      echo -e  "Extracting ${1} to ${DESTDIR}: (7zip compressed file)"
      7za e "${1}" -o "${DESTDIR}"
      ;;
    xz)
      echo -e  "Extracting ${1} : (xz compressed file)"
      unxz  "${1}"
      ;;
    exe)
      cabextract "${1}"
      ;;
    *)
      echo -e "Unknown format!"
      return
      ;;
  esac
}

git config --global --replace-all alias.ranking "!bash -c \"
function git-ranking () {
  if [[ \${#} -eq 0 ]]; then
    git ls-files \
      | xargs -n1 git blame --line-porcelain | sed -n 's/^author //p' \
      | sort -f | uniq -i -c | sort -n -r
  else
    git blame --line-porcelain \$* | sed -n 's/^author //p' | sort -f \
      | uniq -i -c | sort -n -r
  fi
  echo
  github-linguist \$*
}
git-ranking\""

git config --global --replace-all alias.root 'rev-parse --show-toplevel'

git config --global --replace-all alias.file "checkout HEAD -- "

git config --global --replace-all alias.uncommit "reset HEAD^"

git config --global --replace-all alias.unpushed "log --oneline origin/master..master"

alias ga='git add'
alias gaa='git add -A'
alias gam='git add -A && git commit -m'
alias gb='git branch'
alias gc='git clone'
alias gd='tig status'
alias gf='git file'
alias gg='git ranking'
alias gh='git checkout'
alias gl='git pull'
alias gm='git commit -m'
alias gm!='git commit --amend'
alias gp='git push'
alias gp!='git unpushed'
alias gr='git root'
alias gs='git status -s -uall'
alias gsd='git stash drop'
alias gsp='git stash pop'
alias gst='git stash push'
alias gu='git uncommit'

function gamp () {
  git add -A && git commit -m "$@" && git pull && git push
}

alias ti='tig'
alias tb='tig blame'
alias tg='tig grep'

alias tx='direnv exec / tmux'
alias ta='tmux attach'
alias tl='tmux list-sessions'
alias tk='tmux kill-server'

alias du='docker compose up -d'
alias dub='docker compose up -d --build'
alias dd='docker compose down'
alias dls='docker ps -a'
alias dlsi='docker image ls'
alias drm='docker rm -f $(docker ps -a -q)'
alias drmi='docker rmi -f $(docker images -a -q)'
alias dt='docker exec -it'
