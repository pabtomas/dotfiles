#!/bin/sh

OUTPUT_LEN='80'

SEP='#'

ERASE_UNTIL_END='\033[K'

GREEN='\033[38;5;2m'
GREEN2='\033[38;5;10m'
BLUE='\033[38;5;14m'
RED='\033[38;5;9m'
WHITE='\033[38;5;15m'
RESET='\033[m'
BOLD='\033[1m'
RAINBOW="\033[38;5;196m${SEP}\033[38;5;202m${SEP}\033[38;5;208m${SEP}\033[38;5;214m${SEP}\033[38;5;220m${SEP}\033[38;5;226m${SEP}\033[38;5;190m${SEP}\033[38;5;154m${SEP}\033[38;5;118m${SEP}\033[38;5;82m${SEP}\033[38;5;46m${SEP}\033[38;5;47m${SEP}\033[38;5;48m${SEP}\033[38;5;49m${SEP}\033[38;5;50m${SEP}\033[38;5;51m${SEP}\033[38;5;45m${SEP}\033[38;5;39m${SEP}\033[38;5;33m${SEP}\033[38;5;27m${SEP}\033[38;5;21m${SEP}\033[38;5;57m${SEP}\033[38;5;93m${SEP}\033[38;5;129m${SEP}\033[38;5;165m${SEP}\033[38;5;201m${SEP}\033[38;5;200m${SEP}\033[38;5;199m${SEP}\033[38;5;198m${SEP}\033[38;5;197m${SEP}"

MOVE_START_LINE='\033[G'
MOVE_TO_COLX="${MOVE_START_LINE}\033[${OUTPUT_LEN}C"

NL="$(printf '\nx')"
NL="${NL%?}"

NANOS='1000000000'

DEFAULT_SPEED='2'

SUDO='sudo -E'
SUDO_LIFETIME='290'

PM='apt'
ADD_REPO='add-apt-repository -y'
POLICY="${PM} policy"
INSTALL="${SUDO} ${PM} install -y"
UPDATE="${SUDO} ${PM} update -y"
UPGRADE="${SUDO} ${PM} upgrade -y"
AUTOREMOVE="${SUDO} ${PM} autoremove -y"

NOVERSION='unavailable'

ARCH="$(dpkg --print-architecture)"

LOCAL="${HOME}/.local"
LOCAL_SRC="${LOCAL}/src"
LOCAL_SYSTEMD="${HOME}/.config/systemd/user"

POLYGLOT="${HOME}/.vim/pack/plugins/start/vim-polyglot"
TMUXPLUGINS="${HOME}/.tmux/plugins/tpm"
GITTEMPLATES='/usr/share/git-core/templates'

GNOME_THEMES="${HOME}/.themes"
GNOME_ICONS="${HOME}/.icons"
GNOME_LOCAL_ICONS="${LOCAL}/share/icons"

DOT="$(CDPATH= cd -- "$(dirname -- "${0}")" > /dev/null 2>&1 && pwd)"
DOT_VIMRC="${DOT}/vim/.vimrc"
DOT_TMUXCONF="${DOT}/tmux/.tmux.conf"
DOT_TMUXINTMUXCONF="${DOT}/tmux/.tmuxintmux.conf"
DOT_BASHRC="${DOT}/bash/.bashrc"
DOT_PROFILE="${DOT}/sh/.profile"
DOT_ALIASES="${DOT}/bash/.bash_aliases"
DOT_GITIGNORE="${DOT}/git/.gitignore"
DOT_HOOKS="${DOT}/git/.hooks"
DOT_SYSTEMD="${DOT}/systemd"

readonly OUTPUT_LEN \
         SEP \
         ERASE_UNTIL_END \
         BLUE GREEN GREEN2 RED WHITE RESET BOLD RAINBOW \
         MOVE_START_LINE MOVE_TO_COLX \
         NL \
         NANOS \
         DEFAULT_SPEED \
         SUDO SUDO_LIFETIME \
         PM ADD_REPO POLICY INSTALL UPDATE UPGRADE AUTOREMOVE \
         NOVERSION \
         ARCH \
         LOCAL LOCAL_SRC LOCAL_SYSTEMD \
         POLYGLOT TMUXPLUGINS GITTEMPLATES \
         GNOME_THEMES GNOME_ICONS GNOME_LOCAL_ICONS \
         DOT DOT_VIMRC DOT_TMUXCONF DOT_TMUXINTMUXCONF DOT_BASHRC DOT_PROFILE \
         DOT_ALIASES DOT_GITIGNORE DOT_HOOKS DOT_SYSTEMD

_git ()
{
  if git --git-dir "${LOCAL_SRC}/${1}/.git" --work-tree "${LOCAL_SRC}/"${*}
  then
    return 0
  else
    return 1
  fi
}

dashed ()
{
  set -- "${1}" "${OUTPUT_LEN}" "${RAINBOW}" ''
  while [ ${2} -gt 0 ]
  do
    [ -z "${3}" ] && set -- "${1}" "${2}" "${RAINBOW}" "${4}"
    set -- "${1}" "$(( ${2} - 1 ))" "${3#*"${SEP}"}" "${4}${3%%"${SEP}"*}-"
  done
  set -- "${1}" "$(( ${#1} + 1 ))" "${4}"
  while [ ${2} -gt 0 ]
  do
    set -- "${1}" "$(( ${2} - 1 ))" "${3#*-}"
  done
  printf '%b%s%b %b%b ' "${WHITE}" "${1}" "${RESET}" "${3%\\*}" "${RESET}"
  return 0
}

# -- INPUT --
# 1) message
# 2) speed
dots ()
{
  trap 'DOTS_BREAK=""' USR1
  dashed "${1}"
  set -- "$(( $(date '+%s%N') * ${2} / NANOS ))" "${2}"
  set -- "${1}" "${@}"
  while [ -n "${DOTS_BREAK-x}" ]
  do
    set -- "${1}" "${2}" "${3}" "$(( $(date '+%s%N') * ${3} / NANOS ))"
    if [ $(( ${4} - ${1} )) -gt 0 ]
    then
      printf '%b%b.%b' "${WHITE}" "${BOLD}" "${RESET}"
      set -- "$(( $(date '+%s%N') * ${3} / NANOS ))" "${2}" "${3}" "${4}"
    fi
    if [ $(( ${4} - ${2} )) -gt 3 ]
    then
      printf '%b%b' "${MOVE_TO_COLX}" "${ERASE_UNTIL_END}"
      set -- "${1}" "$(( $(date '+%s%N') * ${3} / NANOS ))" "${3}" "${4}"
    fi
  done
  unset DOTS_BREAK
  return 0
}

stop_dots ()
{
  kill -USR1 "${1}"
  wait "${1}" || :
  printf '%b%b' "${MOVE_TO_COLX}" "${ERASE_UNTIL_END}"
  return 0
}

prompt_sudo ()
{
  if [ $(( $(date '+%s') - ${SUDO_LASTPROMPT:-0} )) -gt ${SUDO_LIFETIME} ]
  then
    sudo -k
    SUDO_LASTPROMPT="$(date '+%s')"
    ${SUDO} sh -c ':' || exit 1
  fi
  return 0
}

success ()
{
  printf '%b%bOK%b\n' "${GREEN}" "${BOLD}" "${RESET}"
  return 0
}

error ()
{
  printf '%b%bKO%b\n' "${RED}" "${BOLD}" "${RESET}"
  return 0
}

run ()
{
  dots "${1}" "${DEFAULT_SPEED}" &
  shift
  while [ ${#} -gt 0 ]
  do
    if [ -n "${NEED_EVAL-}" ]
    then
      if [ "${NEED_EVAL%"${NEED_EVAL#?}"}" = "${SEP}" ]
      then
        NEED_EVAL="${NEED_EVAL#"${SEP}"}"
      else
        if ! eval "{ ${1}; } > /dev/null 2>&1"
        then
          stop_dots "${!}"
          error
          exit 1
        fi
        NEED_EVAL="${NEED_EVAL#*"${SEP}"}"
        shift
        continue
      fi
    fi

    if ! ${1} > /dev/null 2>&1
    then
      stop_dots "${!}"
      error
      exit 1
    fi
    shift
  done
  stop_dots "${!}"
  success
  return 0
}

install ()
{
  while [ ${#} -gt 0 ]
  do
    dots "Checking ${1} package installation" "${DEFAULT_SPEED}" &
    if dpkg -l "${1}" > /dev/null 2>&1
    then
      stop_dots "${!}"
      success
    else
      stop_dots "${!}"
      error
      prompt_sudo
      run "Installing ${1} package" "${INSTALL} ${1}"
    fi
    shift
  done
  return 0
}

install_docker ()
{
  if [ ! -e "$(command -v docker)" ]
  then
    prompt_sudo
    curl -f -s -S -L https://download.docker.com/linux/ubuntu/gpg \
      | ${SUDO} gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    prompt_sudo
    printf 'deb [arch=%s signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu %s stable\n' "${ARCH}" "${RELEASE}" \
      | ${SUDO} tee /etc/apt/sources.list.d/docker.list > /dev/null
  fi
  return 0
}

git_install ()
{
  if [ ! -d "${LOCAL_SRC}/${1}" ]
  then
    NEED_EVAL= run "Cloning ${1} repository" "git clone ${2} ${LOCAL_SRC}/${1}"
    NEED_EVAL= run "Adding ${1} repository as a GIT safe repository" \
      "git config --global --add safe.directory ${LOCAL_SRC}/${1}"
    set -- '' '' '' '' "${@}"
  else
    NEED_EVAL= run "Adding ${1} repository as a GIT safe repository" \
      "git config --global --add safe.directory ${LOCAL_SRC}/${1}"
    NEED_EVAL="NEED_EVAL${SEP}" run \
      "Moving to master/main branch into ${1} repository" \
      "_git ${1} checkout master || _git ${1} checkout main"
    NEED_EVAL= run \
      "Checking ${1} remote and local master branches are Up-to-date" \
      "_git ${1} remote update"

    # $1=LOCAL, $2=REMOTE, $3=BASE
    set -- "$(_git "${1}" rev-parse @{0})" "$(_git "${1}" rev-parse @{u})" \
      "$(_git "${1}" merge-base @{0} @{u})" "${@}"

    if [ "${1}" = "${2}" ]
    then
      # Everything is Up-to-date -> Nothing to do
      return 0
    elif [ "${1}" = "${3}" ]
    then
      # Need to pull
      shift 3
      NEED_EVAL= run "Pulling ${1} repository" "_git ${1} pull"
      set -- "$(_git "${1}" rev-list --tags --max-count=1)" "${@}"
      set -- "$(_git "${2}" describe --tags "${1}" 2> /dev/null || :)" "${@}"
      if [ -n "${1}" ] && [ -z "${NOTAG+x}${NOTAG-}" ]
      then
        NEED_EVAL= run "Moving to ${1} tag into ${3} repository" \
          "_git ${3} checkout ${1}"
      fi
      set -- "${1#"${1%%[[:digit:]]*}"}" "${@}"
      set -- "${1%"${1##[[:digit:]]*}"}" "${@}"
    elif [ "${2}" = "${3}" ]
    then
      printf 'Local branch needs to push to remote branch\n' 1>&2
      return 1
    else
      printf 'Local branch and remote branch diverged\n' 1>&2
      return 1
    fi
  fi

  set -- "$(eval "version_${5}")" "${@}"

  if [ ! -e "$(command -v "${6}")" ] || [ "${1%[[:space:]]"${2}"}" != "${6}" ]
  then
    shift 7
    while [ ${#} -gt 0 ]
    do
      case "$(shift; printf '%s\n' "${*}")" in
        *'sudo '*) prompt_sudo ;;
        *) ;;
      esac
      NEED_EVAL="${NEED_EVAL-}" run "${1}" "${2}"
      shift 2
    done
  fi
  return 0
}

version_git ()
{
  if [ -e "$(command -v git)" ]
  then
    set -- "$(git --version)"
    set -- "${1#"${1%%[[:digit:]]*}"}"
    printf 'git %s' "${1}"
  else
    printf 'git %s' "${NOVERSION}"
  fi
  return 0
}

version_docker ()
{
  if [ -e "$(command -v docker)" ]
  then
    set -- "$(docker --version)"
    set -- "${1#"${1%%[[:digit:]]*}"}"
    set -- "${1%,*}"
    printf 'docker %s' "${1}"
  else
    printf 'docker %s' "${NOVERSION}"
  fi
  return 0
}

version_direnv ()
{
  if [ -e "$(command -v direnv)" ] && [ -d "${LOCAL_SRC}/direnv" ]
  then
    set -- "$(_git direnv rev-list --tags --max-count=1)"
    set -- "$(_git direnv describe --tags "${1}")"
    set -- "${1#"${1%%[[:digit:]]*}"}"
    set -- "${1%"${1##[[:digit:]]*}"}"
    printf 'direnv %s' "${1}"
  else
    printf 'direnv %s' "${NOVERSION}"
  fi
  return 0
}

version_vim ()
{
  if [ -e "$(command -v vim)" ] && [ -d "${LOCAL_SRC}/vim" ]
  then
    set -- "$(_git vim rev-list --tags --max-count=1)"
    set -- "$(_git vim describe --tags "${1}")"
    set -- "${1#"${1%%[[:digit:]]*}"}"
    set -- "${1%"${1##[[:digit:]]*}"}"
    printf 'vim %s' "${1}"
  else
    printf 'vim %s' "${NOVERSION}"
  fi
  return 0
}

version_tig ()
{
  if [ -e "$(command -v tig)" ]
  then
    set -- "${IFS}"
    IFS="${NL}"
    set -- "${1}" $(tig --version)
    IFS="${1}"
    set -- "${2#"${2%%[[:digit:]]*}"}"
    printf 'tig %s' "${1}"
  else
    printf 'tig %s' "${NOVERSION}"
  fi
  return 0
}

version_shellcheck ()
{
  if [ -e "$(command -v shellcheck)" ]
  then
    set -- "${IFS}"
    IFS="${NL}"
    set -- "${1}" $(shellcheck --version)
    IFS="${1}"
    set -- "${3#"${3%%[[:digit:]]*}"}"
    printf 'shellcheck %s' "${1}"
  else
    printf 'shellcheck %s' "${NOVERSION}"
  fi
  return 0
}

version_fff ()
{
  if [ -e "$(command -v fff)" ]
  then
    fff -v | tr -d '\n'
  else
    printf 'fff %s' "${NOVERSION}"
  fi
  return 0
}

version_tmux ()
{
  if [ -e "$(command -v tmux)" ]
  then
    tmux -V | tr -d '\n'
  else
    printf 'tmux %s' "${NOVERSION}"
  fi
  return 0
}

version_pass ()
{
  if [ -e "$(command -v pass)" ]
  then
    set -- "${IFS}"
    IFS="${NL}"
    set -- "${1}" $(pass version)
    IFS="${1}"
    set -- "${5#"${5%%[[:digit:]]*}"}"
    set -- "${1%"${1##*[[:digit:]]}"}"
    printf 'pass %s' "${1}"
  else
    printf 'pass %s' "${NOVERSION}"
  fi
  return 0
}

version_linguist ()
{
  if [ -e "$(command -v github-linguist)" ]
  then
    set -- "$(github-linguist --version)"
    set -- "${1#"${1%%[[:digit:]]*}"}"
    printf 'linguist %s' "${1}"
  else
    printf 'linguist %s' "${NOVERSION}"
  fi
  return 0
}

version_polyglot ()
{
  if [ -d "${LOCAL_SRC}/polyglot" ] && [ -d "${POLYGLOT}" ]
  then
    set -- "$(_git polyglot rev-list --tags --max-count=1)"
    set -- "$(_git polyglot describe --tags "${1}")"
    set -- "${1#"${1%%[[:digit:]]*}"}"
    set -- "${1%"${1##[[:digit:]]*}"}"
    printf 'polyglot %s' "${1}"
  else
    printf 'polyglot %s' "${NOVERSION}"
  fi
  return 0
}

version_tpm ()
{
  if [ -d "${LOCAL_SRC}/tpm" ]
  then
    set -- "$(_git tpm rev-list --tags --max-count=1)"
    set -- "$(_git tpm describe --tags "${1}")"
    set -- "${1#"${1%%[[:digit:]]*}"}"
    set -- "${1%"${1##[[:digit:]]*}"}"
    printf 'tpm %s' "${1}"
  else
    printf 'tpm %s' "${NOVERSION}"
  fi
  return 0
}

version_chromethemes ()
{
  if [ -d "${LOCAL_SRC}/chromethemes" ]
  then
    printf 'chromethemes 0'
  else
    printf 'chromethemes %s' "${NOVERSION}"
  fi
  return 0
}

version_candyicons ()
{
  if [ -d "${LOCAL_SRC}/candyicons" ]
  then
    printf 'candyicons 0'
  else
    printf 'candyicons %s' "${NOVERSION}"
  fi
  return 0
}

version_sweetfolders ()
{
  if [ -d "${LOCAL_SRC}/sweetfolders" ]
  then
    printf 'sweetfolders 0'
  else
    printf 'sweetfolders %s' "${NOVERSION}"
  fi
  return 0
}

version_bananacursor ()
{
  if [ -d "${LOCAL_SRC}/bananacursor" ]
  then
    set -- "$(_git bananacursor rev-list --tags --max-count=1)"
    set -- "$(_git bananacursor describe --tags "${1}")"
    set -- "${1#"${1%%[[:digit:]]*}"}"
    set -- "${1%"${1##[[:digit:]]*}"}"
    printf 'bananacursor %s' "${1}"
  else
    printf 'bananacursor %s' "${NOVERSION}"
  fi
  return 0
}

sumup ()
{
  printf '\n'
  while [ -n "${1}" ]
  do
    case "${1%%"${SEP}"*}" in
      *"${NOVERSION}"*) printf '%b' "${BLUE}" ;;
      *) if [ "${1%%"${SEP}"*}" != "$(eval "version_${1%%[[:space:]]*}")" ]
         then
           printf '%b' "${GREEN2}"
         else
           printf '%b' "${WHITE}"
         fi ;;
    esac
    printf '%b%s -> ' "${BOLD}" "${1%%"${SEP}"*}"
    eval "version_${1%%[[:space:]]*}"
    set -- "${1#*"${SEP}"}"
    printf '%b\n' "${RESET}"
  done
  printf '\n'
  return 0
}

main ()
{
  set -eu

  prompt_sudo

  # -- ARGS --
  # 1) is GNOME installed ?
  # 2) old versions
  set -- 'true' ''

  mkdir -p "${LOCAL}/bin" "${LOCAL}/share" "${LOCAL}/lib" "${LOCAL_SRC}" \
    "${LOCAL_SYSTEMD}" "${POLYGLOT}" "${TMUXPLUGINS}" "${GNOME_THEMES}" \
    "${GNOME_ICONS}"

  dashed 'Checking GNOME installation'
  if [ "${XDG_CURRENT_DESKTOP##*:}" = 'GNOME' ] && \
    [ -e "$(command -v gnome-shell)" ]
  then
    success
  else
    error
    set -- 'false' "${2}"
  fi

  dashed 'Checking bluetooth service'
  if [ -f /etc/init.d/bluetooth ]
  then
    success

    prompt_sudo
    run 'Disabling bluetooth service' "${SUDO} systemctl disable bluetooth.service" \
      '/lib/systemd/systemd-sysv-install disable bluetooth'
  else
    error
    return 1
  fi

  if ! command -v lsb_release > /dev/null
  then
    prompt_sudo
    run 'Updating system' "${UPDATE}"
    install lsb-release
  fi

  RELEASE="$(lsb_release -cs)"
  readonly RELEASE

  dashed 'Checking mesa drivers ppa'
  case "${RELEASE}" in
    focal) PPA_REPO='kisak/kisak-mesa' ;;
    jammy) PPA_REPO='oibaf/graphics-drivers' ;;
    *) error
       printf 'Unknown %s release\n' "${RELEASE}" 1>&2
       return 1 ;;
  esac
  case "$(${POLICY} 2> /dev/null)" in
    *"${PPA_REPO}"*) success ;;
    *) error
       set -f
       run 'Adding mesa drivers ppa' "${SUDO} ${ADD_REPO} ppa:${PPA_REPO}"
       set +f ;;
  esac

  dashed 'Checking git ppa'
  PPA_REPO='git-core/ppa'
  case "$(${POLICY} 2> /dev/null)" in
    *"${PPA_REPO}"*) success ;;
    *) error
       set -f
       run 'Adding git-core ppa' "${SUDO} ${ADD_REPO} ppa:${PPA_REPO}"
       set +f ;;
  esac

  set -- "${1}" "${2}$(version_git)${SEP}"
  set -- "${1}" "${2}$(version_docker)${SEP}"
  set -- "${1}" "${2}$(version_direnv)${SEP}"
  set -- "${1}" "${2}$(version_vim)${SEP}"
  set -- "${1}" "${2}$(version_tig)${SEP}"
  set -- "${1}" "${2}$(version_shellcheck)${SEP}"
  set -- "${1}" "${2}$(version_fff)${SEP}"
  set -- "${1}" "${2}$(version_tmux)${SEP}"
  set -- "${1}" "${2}$(version_pass)${SEP}"
  set -- "${1}" "${2}$(version_linguist)${SEP}"
  set -- "${1}" "${2}$(version_polyglot)${SEP}"
  set -- "${1}" "${2}$(version_chromethemes)${SEP}"
  set -- "${1}" "${2}$(version_candyicons)${SEP}"
  set -- "${1}" "${2}$(version_sweetfolders)${SEP}"
  set -- "${1}" "${2}$(version_bananacursor)${SEP}"

  prompt_sudo
  run 'Updating system' "${UPDATE}"

  prompt_sudo
  run 'Upgrading system' "${UPGRADE}"

  prompt_sudo
  run 'Removing unused packages' "${AUTOREMOVE}"

  # for CLI
  install git tree curl jq silversearcher-ag build-essential make autoconf \
    automake cmake kcolorchooser libreoffice-gnome libreoffice gnome-tweaks \
    gnome-shell-extensions dbus-x11

  # for GNOME extensions and themes
  install gtk2-engines-murrine gtk2-engines-pixbuf

  # for spaceporn
  install libpng-dev libsystemd-dev libglew-dev libx11-dev

  # for password-store
  install xclip

  # for password-store and docker
  install gnupg

  # for linguist
  install ruby-dev libicu-dev zlib1g-dev libcurl4-openssl-dev libssl-dev

  # for shellcheck
  install cabal-install
  run 'Updating cabal' 'cabal update'
  set -- "${@}" "${IFS}"
  IFS="${NL}"
  set -- "${@}" $(cabal --version)
  IFS="${3}"
  set -- "${1}" "${2}" "${4##*[[:space:]]}"
  if [ "${3%%.*}" -lt 3 ]
  then
    run 'Installing cabal 3' 'cabal install --reinstall cabal-install'
    prompt_sudo
    run 'Creating cabal 3 symbolic link' "sudo ln -s -f ${HOME}/.cabal/bin/cabal $(command -v cabal)"
  fi
  set -- "${1}" "${2}"
  run 'Cleaning cabal temporary files' 'cabal clean'

  # for docker
  install ca-certificates lsb-release

  # for vim
  install libtool-bin

  # for vim clipboard feature
  install libxt-dev

  # for vim GUI server-client feature
  install libgtk-3-dev

  # for tmux
  install libevent-dev bison

  # for vim, tmux and tig
  install gcc-10 gcc-10-base gcc-10-doc g++-10 libstdc++-10-dev \
    libstdc++-10-doc libncurses-dev

  # for tmux and tig
  install pkg-config

  # for tig documentation
  install asciidoc

  # for .tmux.conf
  install xsel

  dashed 'Resetting GIT safe repositories'
  git config --global --unset-all safe.directory && success || success

  prompt_sudo
  run 'Adding symbolic link to gcc 10 and g++ 10' \
    "${SUDO} ln -f -s $(command -v gcc-10) $(command -v gcc)" \
    "${SUDO} ln -f -s $(command -v g++-10) $(command -v g++)"

  install_docker

  # for docker
  install docker-ce docker-ce-cli containerd.io docker-compose-plugin

  NEED_EVAL="NEED_EVAL${SEP}" git_install 'direnv' \
    'https://github.com/direnv/direnv' 'Installing direnv' \
    "cd ${LOCAL_SRC}/direnv && sudo bash install.sh && cd -"
  git_install 'vim' 'https://github.com/vim/vim' 'Compiling vim' \
    "make --directory ${LOCAL_SRC}/vim" 'Installing vim' \
    "${SUDO} make --directory ${LOCAL_SRC}/vim install"
  git_install 'tig' 'https://github.com/jonas/tig' 'Compiling tig' \
    "make --directory ${LOCAL_SRC}/tig clean all prefix=${LOCAL}" \
    'Installing tig' \
    "make --directory ${LOCAL_SRC}/tig install prefix=${LOCAL}" \
    'Documenting tig' \
    "${SUDO} make --directory ${LOCAL_SRC}/tig install-doc prefix=/usr"
  NEED_EVAL="NEED_EVAL${SEP}" git_install 'shellcheck' \
    'https://github.com/koalaman/shellcheck' 'Installing shellcheck' \
    "cd ${LOCAL_SRC}/shellcheck && cabal install --overwrite-policy=always --installdir=${HOME}/.cabal/bin && cd -"
  NOTAG='true' git_install 'fff' 'https://github.com/dylanaraps/fff' \
    'Installing fff' "make --directory ${LOCAL_SRC}/fff PREFIX=${LOCAL} install"
  NEED_EVAL="NEED_EVAL${SEP}NEED_EVAL${SEP}${SEP}${SEP}" git_install 'tmux' \
    'https://github.com/tmux/tmux' 'Generating tmux configuration' \
    "cd ${LOCAL_SRC}/tmux && sh autogen.sh && cd -" 'Configuring tmux' \
    "cd ${LOCAL_SRC}/tmux && ./configure && cd -" 'Compiling tmux' \
    "make --directory ${LOCAL_SRC}/tmux" 'Installing tmux' \
    "${SUDO} make --directory ${LOCAL_SRC}/tmux install"
  NOTAG='true' git_install 'pass' 'https://git.zx2c4.com/password-store' \
    'Installing password-store' \
    "${SUDO} make install --directory ${LOCAL_SRC}/pass"
  NEED_EVAL="NEED_EVAL${SEP}" git_install 'linguist' \
    'https://github.com/github/linguist' 'Installing/Updating github-linguist' \
    "if command -v github-linguist; then ${SUDO} gem update github-linguist; else ${SUDO} gem install github-linguist; fi"

  run 'Copying .vimrc' "cp -f ${DOT_VIMRC} ${HOME}"

  NEED_EVAL="NEED_EVAL${SEP}" NOTAG='true' git_install 'polyglot' \
    'https://github.com/sheerun/vim-polyglot' \
    'Copying polyglot to vim plugins directory' \
    "(set -- ${LOCAL_SRC}/polyglot/*;"' while [ ${#} -gt 0 ]; do case "${1}" in *.git) ;; *) cp -a -f "${1}"'" ${POLYGLOT} ;; esac; shift; done)"

  run 'Copying .tmux.conf' "cp -f ${DOT_TMUXCONF} ${HOME}"
  run 'Copying .tmuxintmux.conf' "cp -f ${DOT_TMUXINTMUXCONF} ${HOME}"

  NEED_EVAL="NEED_EVAL${SEP}" NOTAG='true' git_install 'tpm' 'https://github.com/tmux-plugins/tpm' \
    'Copying tpm into .tmux directory' \
    "(set -- ${LOCAL_SRC}/tpm/*;"' while [ ${#} -gt 0 ]; do case "${1}" in *.git) ;; *) cp -a "${1}"'" ${TMUXPLUGINS} ;; esac; shift; done)"

  run 'Installing tmux plugins' "${TMUXPLUGINS}/bin/install_plugins"

  NEED_EVAL="${SEP}NEED_EVAL${SEP}" run 'Copying .bashrc' \
    "cp -f /etc/skel/.bashrc ${HOME}" \
    "cat ${DOT_BASHRC} >> ${HOME}/.bashrc"

  NEED_EVAL="${SEP}NEED_EVAL${SEP}" run 'Copying .profile' \
    "cp -f /etc/skel/.profile ${HOME}/.profile" \
    "cat ${DOT_PROFILE} >> ${HOME}/.profile"

  run 'Copying .bash_aliases' "cp -f ${DOT_ALIASES} ${HOME}/.bash_aliases"

  prompt_sudo
  run 'Copying .gitignore' "sudo cp -f ${DOT_GITIGNORE} ${GITTEMPLATES}"

  prompt_sudo
  run 'Copying hooks' "sudo cp -a -f ${DOT_HOOKS} ${GITTEMPLATES}"

  if [ "${1}" = 'true' ]
  then
    dashed 'Checking GNOME version'
    set -- "$(gnome-shell --version)" "${@}"
    set -- "${1##*[[:space:]]}\n3.30.1\n" "${@}"
    if [ "$(printf '%b' "${1}" | sort -V | head -n1)" = '3.30.1' ]
    then
      success
      run 'Enabling GNOME extensions' \
        'gsettings set org.gnome.shell disable-user-extensions false'
      run 'Hidding desktop icons' \
        'gsettings set org.gnome.desktop.background show-desktop-icons false'

      case "$(gnome-extensions list)" in
        *'desktop-icons@csoriano'*) run 'Disabling desktop-icons extension' \
          'gsettings set org.gnome.shell.extensions.desktop-icons show-home false' \
          'gsettings set org.gnome.shell.extensions.desktop-icons show-trash false' \
          'gnome-extensions disable desktop-icons@csoriano' ;;
        *'ding@rastersoft'*) run 'Disabling ding extension' \
          'gsettings set org.gnome.shell.extensions.ding show-home false' \
          'gsettings set org.gnome.shell.extensions.ding show-trash false' \
          'gnome-extensions disable ding@rastersoft.com' ;;
        *) error
           printf 'Unknown desktop icon extension\n' 1>&2
           return 1 ;;
      esac

      NOTAG='true' git_install 'chromethemes' 'https://github.com/rtlewis1/GTK' \
        'Moving to Chrome OS themes branch' \
        '_git chromethemes checkout remotes/origin/ChromeOS-Dark' \
        'Copying UltraViolet theme' \
        "cp -a -f ${LOCAL_SRC}/chromethemes/ChromeOS-Darker-UltraViolet-Rounded ${GNOME_THEMES}"

      NOTAG='true' git_install 'candyicons' \
        'https://github.com/EliverLara/candy-icons' 'Copying candy icons' \
        "cp -a -f ${LOCAL_SRC}/candyicons ${GNOME_ICONS}" \
        'Creating candy-link symbolic link' \
        "ln -s -f ${GNOME_ICONS}/candyicons ${GNOME_ICONS}/candy-icons"

      NOTAG='true' git_install 'sweetfolders' \
        'https://github.com/EliverLara/Sweet-folders' 'Copying sweet folders' \
        "cp -a -f ${LOCAL_SRC}/sweetfolders ${GNOME_LOCAL_ICONS}"

      URL="$(curl -s https://api.github.com/repos/ful1e5/banana-cursor/releases/latest \
        | jq -r '.assets[] | select(.name | test("tar.gz")) | .browser_download_url')"
      readonly URL

      git_install 'bananacursor' 'https://github.com/ful1e5/banana-cursor' \
        'Download banana cursor archive' \
        "curl -L ${URL} --output ${GNOME_ICONS}/Banana.tar.gz" \
        'Unarchive the banana cursor' \
        "tar xf ${GNOME_ICONS}/Banana.tar.gz -C ${GNOME_ICONS}" \
        'Removing archives' "rm -f ${GNOME_ICONS}/Banana.tar.gz"

      run 'Setting GNOME Interface' \
        'gsettings set org.gnome.desktop.interface show-battery-percentage true' \
        'gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true' \
        'gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-automatic false' \
        'gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-from 0.0' \
        'gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-to 0.0' \
        'gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com' \
        "gsettings set org.gnome.desktop.interface cursor-theme 'Banana'" \
        "gsettings set org.gnome.desktop.interface icon-theme 'Sweet-Rainbow'" \
        "gsettings set org.gnome.desktop.interface gtk-theme 'ChromeOS-Darker-UltraViolet-Rounded'" \
        "gsettings set org.gnome.shell.extensions.user-theme name 'ChromeOS-Darker-UltraViolet-Rounded'"

      run 'Deploy systemd timers' "cp -f ${DOT_SYSTEMD}/* ${LOCAL_SYSTEMD}" \
        'systemctl --user enable bluelight.service' \
        'systemctl --user enable bluelight.timer' \
        'systemctl --user start bluelight.timer' \
        'systemctl --user daemon-reload'

      shift 2
    else
      error
      gnome-shell --version
      set -- 'false' "${4}"
    fi
  fi

  sumup "${2}"

  return 0
}

main
