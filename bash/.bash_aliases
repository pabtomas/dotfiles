mario () {
  vim -u /etc/vim/vimrc -N -c "execute \"Mario\" | tabonly | set nowrap | normal! G | echo \"Poisson d'avril ! Quitter = Q, Jouer = Haut, Gauche, Droite et mettre la police du terminal à 6"
}

tbm () {
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

colors () { curl -s https://gist.githubusercontent.com/HaleTom/89ffe32783f89f403bba96bd7bcd1263/raw/ | bash; }

ls () { ls --color "${@}"; }
grep () { grep --color "${@}"; }
diff () { diff -u --color "${@}"; }
ag () { ag -t --hidden --color --multiline --numbers --pager "less -R" "${@}"; }
agi () { ag --hidden --color --multiline --numbers --pager "less -R" --ignore "${@}"; }
tree () { tree -C "${@}"; }
watch () { watch -c -n 1 "${@}"; }
ps () { ps -a -x "${@}"; }
rm () { rm -i -r -v "${@}"; }
cp () { cp -i -r -v "${@}"; }
mv () { mv -i -n -v "${@}"; }
ln () { ln -i -v "${@}"; }
rl () { readlink -m "${@}"; }
mkdir () { mkdir -p -v "${@}"; }
sudo () { sudo  "${@}"; }
cal () { ncal -w -b -M "${@}"; }
vi () { vim "${@}"; }
ip () { hostname -I "${@}"; }
less () { less -R "${@}"; }

set 1 2 3 4
while [ "${*}" ]
do
  alias ."$(printf '.%0.s' "${@}")"='cd '"$(printf '../%0.s' "${@}")"
  shift
done

extract () {
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
  local FILE="$(basename "${1}")"

  case "${FILE##*.}" in
    tar)
      echo -e "Extracting ${1} to ${DIR}: (uncompressed tar)"
      tar xvf "${1}" -C "${DIR}" ;;
    gz)
      echo -e "Extracting ${1} to ${DIR}: (gip compressed tar)"
      tar xvfz "${1}" -C "${DIR}" ;;
    tgz)
      echo -e "Extracting ${1} to ${DIR}: (gip compressed tar)"
      tar xvfz "${1}" -C "${DIR}" ;;
    xz)
      echo -e "Extracting  ${1} to ${DIR}: (gip compressed tar)"
      tar xvf -J "${1}" -C "${DIR}" ;;
    bz2)
      echo -e "Extracting ${1} to ${DIR}: (bzip compressed tar)"
      tar xvfj "${1}" -C "${DIR}" ;;
    tbz2)
      echo -e "Extracting ${1} to ${DIR}: (tbz2 compressed tar)"
      tar xvjf "${1}" -C "${DIR}" ;;
    zip)
      echo -e "Extracting ${1} to ${DIR}: (zip compressed file)"
      unzip "${1}" -d "${DIR}" ;;
    lzma)
      echo -e "Extracting ${1} : (lzma compressed file)"
      unlzma "${1}" ;;
    rar)
      echo -e "Extracting ${1} to ${DIR}: (rar compressed file)"
      unrar x "${1}" "${DIR}" ;;
    7z)
      echo -e  "Extracting ${1} to ${DIR}: (7zip compressed file)"
      7za e "${1}" -o "${DIR}" ;;
    xz)
      echo -e  "Extracting ${1} : (xz compressed file)"
      unxz  "${1}" ;;
    exe)
      cabextract "${1}" ;;
    *)
      echo -e "Unknown format"
      return ;;
  esac
}

git config --global --replace-all alias.ranking "!bash -c \"
git-ranking () {
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

ga () { git add "${@}"; }
gaa () { git add -A "${@}"; }
gam () { git add -A && git commit -m "${@}"; }
gamp () { git add -A && git commit -m "$@" && git pull && git push; }
gb () { git branch "${@}"; }
gc () { git clone "${@}"; }
gd () { tig status "${@}"; }
gf () { git file "${@}"; }
gg () { git ranking "${@}"; }
gh () { git checkout "${@}"; }
gl () { git pull "${@}"; }
gm () { git commit -m "${@}"; }
gma () { git commit --amend "${@}"; }
gp () { git push "${@}"; }
gpl () { git unpushed "${@}"; }
gr () { git root "${@}"; }
gs () { git status -s -uall "${@}"; }
gsd () { git stash drop "${@}"; }
gsp () { git stash pop "${@}"; }
gst () { git stash push "${@}"; }
gu () { git uncommit "${@}"; }

ti () { tig "${@}"; }
tb () { tig blame "${@}"; }
tg () { tig grep "${@}"; }

tx () { direnv exec / tmux "${@}"; }
ta () { tmux attach "${@}"; }
tl () { tmux list-sessions "${@}"; }
tk () { tmux kill-server "${@}"; }

du () { docker compose up -d "${@}"; }
dub () { docker compose up -d --build "${@}"; }
dd () { docker compose down "${@}"; }
dls () { docker ps -a "${@}"; }
dlsi () { docker image ls "${@}"; }
drm () { docker rm -f "$(docker ps -a -q)" "${@}"; }
drmi () { docker rmi -f "$(docker images -a -q)" "${@}"; }
dt () { if [[ ${dt_USER} ]]; then docker exec -it --user "${dt_USER}" "${@}"; else docker exec -it "${@}"; fi; }
