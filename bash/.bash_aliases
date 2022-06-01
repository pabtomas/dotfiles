function mario () {
  command vim -u /etc/vim/vimrc -N -c "execute \"Mario\" | tabonly | set nowrap | normal! G | echo \"Poisson d'avril ! Quitter = Q, Jouer = Haut, Gauche, Droite et mettre la police du terminal à 6"
}

function tbm () {
  while :
  do
    local D B1 B1b B2 B2b T1 T1b T2 T2b IN
    D=$(printf "%(%A %d %B %Y %H:%M:%S)T")
    B1="$(command curl https://ws.infotbm.com/ws/1.0/get-realtime-pass/3049/03 2> /dev/null | command jq -r '.destinations[][] | "\(.waittime_text) \(.destination_name) \(.arrival_theorique)"')"
    B1b="$(printf "%s\n" "${B1}" | command grep -E "heure" | command sort -n | command uniq | command sed -e "s/\([[:alpha:]]\)\([[:alpha:]]*\)/\1\L\2/g; s/:[[:digit:]]\{2\}$//; s/[[:digit:]]\{4,\}-[[:digit:]]\{2\}-[[:digit:]]\{2\} //")"
    [[ ${#B1b} -gt 0 ]] && B1b="${B1b}\n"
    B1="$(printf "%s\n" "${B1}" | command grep -vE "heure" | command sort -n | command uniq | command sed -e "s/\([[:alpha:]]\)\([[:alpha:]]*\)/\1\L\2/g; s/:[[:digit:]]\{2\}$//; s/[[:digit:]]\{4,\}-[[:digit:]]\{2\}-[[:digit:]]\{2\} //")"
    B2="$(command curl https://ws.infotbm.com/ws/1.0/get-realtime-pass/112/71 2> /dev/null | command jq -r '.destinations[][] | "\(.waittime_text) \(.destination_name) \(.arrival_theorique)"')"
    B2b="$(printf "%s\n" "${B2}" | command grep -E "heure" | command sort -n | command uniq | command sed -e "s/\([[:alpha:]]\)\([[:alpha:]]*\)/\1\L\2/g; s/:[[:digit:]]\{2\}$//; s/[[:digit:]]\{4,\}-[[:digit:]]\{2\}-[[:digit:]]\{2\} //")"
    [[ ${#B2b} -gt 0 ]] && B2b="${B2b}\n"
    B2="$(printf "%s\n" "${B2}" | command grep -vE "heure" | command sort -n | command uniq | command sed -e "s/\([[:alpha:]]\)\([[:alpha:]]*\)/\1\L\2/g; s/:[[:digit:]]\{2\}$//; s/[[:digit:]]\{4,\}-[[:digit:]]\{2\}-[[:digit:]]\{2\} //")"
    T1="$(command curl https://ws.infotbm.com/ws/1.0/get-realtime-pass/3696/A 2> /dev/null | command jq -r '.destinations[][] | "\(.waittime_text) \(.destination_name) \(.arrival_theorique)"')"
    T1b="$(printf "%s\n" "${T1}" | command grep -E "heure" | command sort -n | command uniq | command sed -e "s/\([[:alpha:]]\)\([[:alpha:]]*\)/\1\L\2/g; s/:[[:digit:]]\{2\}$//; s/[[:digit:]]\{4,\}-[[:digit:]]\{2\}-[[:digit:]]\{2\} //")"
    [[ ${#T1b} -gt 0 ]] && T1b="${T1b}\n"
    T1="$(printf "%s\n" "${T1}" | command grep -vE "heure" | command sort -n | command uniq | command sed -e "s/\([[:alpha:]]\)\([[:alpha:]]*\)/\1\L\2/g; s/:[[:digit:]]\{2\}$//; s/[[:digit:]]\{4,\}-[[:digit:]]\{2\}-[[:digit:]]\{2\} //")"
    T2="$(command curl https://ws.infotbm.com/ws/1.0/get-realtime-pass/3715/A 2> /dev/null | command jq -r '.destinations[][] | "\(.waittime_text) \(.destination_name) \(.arrival_theorique)"')"
    T2b="$(printf "%s\n" "${T2}" | command grep -E "heure" | command sort -n | command uniq | command sed -e "s/\([[:alpha:]]\)\([[:alpha:]]*\)/\1\L\2/g; s/:[[:digit:]]\{2\}$//; s/[[:digit:]]\{4,\}-[[:digit:]]\{2\}-[[:digit:]]\{2\} //")"
    [[ ${#T2b} -gt 0 ]] && T2b="${T2b}\n"
    T2="$(printf "%s\n" "${T2}" | command grep -vE "heure" | command sort -n | command uniq | command sed -e "s/\([[:alpha:]]\)\([[:alpha:]]*\)/\1\L\2/g; s/:[[:digit:]]\{2\}$//; s/[[:digit:]]\{4,\}-[[:digit:]]\{2\}-[[:digit:]]\{2\} //")"
    clear
    printf "${D}\n\n🚍 \033[1;37;1;44m 3 \033[0m Collège Hastignan\n${B1}\n${B1b}\n🚍 \033[1;37;1;42m 71 \033[0m Cerema\n${B2}\n${B2b}\n🚇 \033[1;37m\033[1;48;5;198m A \033[0m Palmer\n${T1}\n${T1b}\n🚇 \033[1;37m\033[1;48;5;198m A \033[0m Place Du Palais\n${T2}\n${T2b}\nPress Q to quit"
    read -s -n 1 -t 1 IN <&1
    [[ ${IN} == "q" ]] && break
  done
  clear
}

function colors () { command curl -s https://gist.githubusercontent.com/HaleTom/89ffe32783f89f403bba96bd7bcd1263/raw/ | bash; }

function ls () { command ls --color "${@}"; }
function grep () { command grep --color "${@}"; }
function diff () { command diff -u --color "${@}"; }
function ag () { command ag -t --hidden --color --multiline --numbers --pager "less -R" "${@}"; }
function agi () { command ag --hidden --color --multiline --numbers --pager "less -R" --ignore "${@}"; }
function tree () { command tree -C "${@}"; }
function watch () { printf '\033[s\033[?1049h\033[?7l\033[?25l\033[H'; stty -echo; while :; do printf '\033[2J\033[H'; eval "${@}"; unset IN; read -r -n 1 -t 1 IN; [[ ${IN} == q ]] && break; done; pr    intf '\033[?7h\033[?25h\033[2J\033[?1049l\033[u'; stty echo; }
function ps () { command ps -a -x "${@}"; }
function rm () { command rm -i -r -v "${@}"; }
function cp () { command cp -i -r -v "${@}"; }
function mv () { command mv -i -n -v "${@}"; }
function ln () { command ln -i -v "${@}"; }
function rl () { command readlink -m "${@}"; }
function mkdir () { command mkdir -p -v "${@}"; }
alias sudo='sudo '
function cal () { command ncal -w -b -M "${@}"; }
function vi () { command vim "${@}"; }
function ip () { command hostname -I "${@}"; }
function less () { command less -R "${@}"; }

set 1 2 3 4
while [ "${*}" ]
do
  alias ."$(printf '.%0.s' "${@}")"='cd '"$(printf '../%0.s' "${@}")"
  shift
done

function extract () {
  # Not enough args
  if [[ ${#} -lt 1 ]]; then
    echo "Usage: extract <path/file_name>"\
      ".<zip|rar|bz2|gz|tar|tbz2|tgz|Z|7z|xz|ex|tar.bz2|tar.gz|tar.xz>"
    return 1
  fi

  # File not found
  if [[ ! -e ${1} ]]; then
    echo -e "File does not exist!"
    return 2
  fi

  # Extracted dir already exists
  local DIR="${1}_extracted"
  if [[ -d ${DIR} ]]; then
    echo -e "${DIR} already exists. Can't extract in a safe destination."
    return 3
  fi

  mkdir "${DIR}"
  local FILE="$(command basename "${1}")"

  case "${FILE##*.}" in
    tar)
      echo -e "Extracting ${1} to ${DIR}: (uncompressed tar)"
      command tar xvf "${1}" -C "${DIR}" ;;
    gz)
      echo -e "Extracting ${1} to ${DIR}: (gip compressed tar)"
      command tar xvfz "${1}" -C "${DIR}" ;;
    tgz)
      echo -e "Extracting ${1} to ${DIR}: (gip compressed tar)"
      command tar xvfz "${1}" -C "${DIR}" ;;
    xz)
      echo -e "Extracting  ${1} to ${DIR}: (gip compressed tar)"
      command tar xvf -J "${1}" -C "${DIR}" ;;
    bz2)
      echo -e "Extracting ${1} to ${DIR}: (bzip compressed tar)"
      command tar xvfj "${1}" -C "${DIR}" ;;
    tbz2)
      echo -e "Extracting ${1} to ${DIR}: (tbz2 compressed tar)"
      command tar xvjf "${1}" -C "${DIR}" ;;
    zip)
      echo -e "Extracting ${1} to ${DIR}: (zip compressed file)"
      command unzip "${1}" -d "${DIR}" ;;
    lzma)
      echo -e "Extracting ${1} : (lzma compressed file)"
      command unlzma "${1}" ;;
    rar)
      echo -e "Extracting ${1} to ${DIR}: (rar compressed file)"
      command unrar x "${1}" "${DIR}" ;;
    7z)
      echo -e  "Extracting ${1} to ${DIR}: (7zip compressed file)"
      command 7za e "${1}" -o "${DIR}" ;;
    xz)
      echo -e  "Extracting ${1} : (xz compressed file)"
      command unxz  "${1}" ;;
    exe)
      command cabextract "${1}" ;;
    *)
      echo -e "Unknown format"
      return ;;
  esac
}

git config --global --replace-all alias.ranking "!bash -c \"
function git-ranking () {
  if [[ \${#} -eq 0 ]]; then
    command git ls-files \
      | command xargs -n1 \git blame --line-porcelain | command sed -n 's/^author //p' \
      | command sort -f | command uniq -i -c | command sort -n -r
  else
    command git blame --line-porcelain \$* | command sed -n 's/^author //p' | command sort -f \
      | command uniq -i -c | command sort -n -r
  fi
  echo
  command github-linguist \$*
}
git-ranking\""

git config --global --replace-all alias.root 'rev-parse --show-toplevel'
git config --global --replace-all alias.file "checkout HEAD -- "
git config --global --replace-all alias.uncommit "reset HEAD^"
git config --global --replace-all alias.unpushed "log --oneline origin/master..master"

function ga () { command git add "${@}"; }
function gaa () { command git add -A "${@}"; }
function gam () { command git add -A && command git commit -m "${@}"; }
function gamp () { command git add -A && command git commit -m "$@" && command git pull && command git push; }
function gb () { command git branch "${@}"; }
function gc () { command git clone "${@}"; }
function gd () { tig status "${@}"; }
function gf () { command git file "${@}"; }
function gg () { command git ranking "${@}"; }
function gh () { command git checkout "${@}"; }
function gl () { command git pull "${@}"; }
function gm () { command git commit -m "${@}"; }
function gma () { command git commit --amend "${@}"; }
function gp () { command git push "${@}"; }
function gpl () { command git unpushed "${@}"; }
function gr () { command git root "${@}"; }
function gs () { command git status -s -uall "${@}"; }
function gsd () { command git stash drop "${@}"; }
function gsp () { command git stash pop "${@}"; }
function gst () { command git stash push "${@}"; }
function gu () { command git uncommit "${@}"; }

function ti () { command tig "${@}"; }
function tb () { command tig blame "${@}"; }
function tg () { command tig grep "${@}"; }

function tx () { command direnv exec / \tmux "${@}"; }
function ta () { command tmux attach "${@}"; }
function tl () { command tmux list-sessions "${@}"; }
function tk () { command tmux kill-server "${@}"; }

function du () { command docker compose up -d "${@}"; }
function dub () { command docker compose up -d --build "${@}"; }
function dd () { command docker compose down "${@}"; }
function dls () { command docker ps -a "${@}"; }
function dlsi () { command docker image ls "${@}"; }
function drm () { command docker rm -f "$(command docker ps -a -q)" "${@}"; }
function drmi () { command docker rmi -f "$(command docker images -a -q)" "${@}"; }
function dt () { if [[ ${dt_USER} ]]; then command docker exec -it --user "${dt_USER}" "${@}"; else command docker exec -it "${@}"; fi; }
