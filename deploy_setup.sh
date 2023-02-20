#!/bin/sh

has ()
{
  set -- "$(command -v "${1}")" 2> /dev/null || return 1
  [ -x "${1}" ] || return 1
  return 0
}

setup_outputlen='80'

setup_sep='#'

setup_eraseuntilend='\033[K'

setup_green='\033[38;5;2m'
setup_green2='\033[38;5;10m'
setup_blue='\033[38;5;14m'
setup_red='\033[38;5;9m'
setup_white='\033[38;5;15m'
setup_reset='\033[m'
setup_bold='\033[1m'
setup_rainbow="\033[38;5;196m${setup_sep}\033[38;5;202m${setup_sep}\033[38;5;208m${setup_sep}\033[38;5;214m${setup_sep}\033[38;5;220m${setup_sep}\033[38;5;226m${setup_sep}\033[38;5;190m${setup_sep}\033[38;5;154m${setup_sep}\033[38;5;118m${setup_sep}\033[38;5;82m${setup_sep}\033[38;5;46m${setup_sep}\033[38;5;47m${setup_sep}\033[38;5;48m${setup_sep}\033[38;5;49m${setup_sep}\033[38;5;50m${setup_sep}\033[38;5;51m${setup_sep}\033[38;5;45m${setup_sep}\033[38;5;39m${setup_sep}\033[38;5;33m${setup_sep}\033[38;5;27m${setup_sep}\033[38;5;21m${setup_sep}\033[38;5;57m${setup_sep}\033[38;5;93m${setup_sep}\033[38;5;129m${setup_sep}\033[38;5;165m${setup_sep}\033[38;5;201m${setup_sep}\033[38;5;200m${setup_sep}\033[38;5;199m${setup_sep}\033[38;5;198m${setup_sep}\033[38;5;197m${setup_sep}"

setup_movestartline='\033[G'
setup_movetocolx="${setup_movestartline}\033[${setup_outputlen}C"

setup_newline="$(printf '\nx')"
setup_newline="${setup_newline%?}"

setup_nanos='1000000000'

setup_defaultspeed='2'

_sudo='sudo -E'
setup_sudolifetime='290'

_pm='apt'
_addrepo='add-apt-repository -y'
_pm_policy="${_pm} policy"
_pm_install="${_sudo} ${_pm} install -y"
_pm_update="${_sudo} ${_pm} update -y"
_pm_upgrade="${_sudo} ${_pm} upgrade -y"
_pm_clean="${_sudo} ${_pm} autoremove -y"

setup_noversion='unavailable'

setup_arch="$(dpkg --print-architecture)"
setup_user="${USER:-$(if has id; then id -un; elif has whoami; then whoami; fi)}"

setup_local="${HOME}/.local"
setup_localsrc="${setup_local}/src"
setup_localsystemd="${HOME}/.config/systemd/user"

setup_polyglot="${HOME}/.vim/pack/plugins/start/vim-polyglot"
setup_tpm="${HOME}/.tmux/plugins/tpm"
setup_gittemplates='/usr/share/git-core/templates'

setup_gnomethemes="${HOME}/.themes"
setup_gnomeicons="${HOME}/.icons"
setup_gnomelocalicons="${setup_local}/share/icons"

setup_dot="$(CDPATH= cd -- "$(dirname -- "${0}")" > /dev/null 2>&1 && pwd)"
setup_dot_vimrc="${setup_dot}/vim/.vimrc"
setup_dot_tmuxconf="${setup_dot}/tmux/.tmux.conf"
setup_dot_tmuxintmuxconf="${setup_dot}/tmux/.tmuxintmux.conf"
setup_dot_bashrc="${setup_dot}/bash/.bashrc"
setup_dot_profile="${setup_dot}/sh/.profile"
setup_dot_aliases="${setup_dot}/bash/.bash_aliases"
setup_dot_gitignore="${setup_dot}/git/.gitignore"
setup_dot_hooks="${setup_dot}/git/.hooks"
setup_dot_systemd="${setup_dot}/systemd"

readonly setup_outputlen \
         setup_sep \
         setup_eraseuntilend \
         setup_blue setup_green setup_green2 setup_red setup_white setup_reset setup_bold setup_rainbow \
         setup_movestartline setup_movetocolx \
         setup_newline \
         setup_nanos \
         setup_defaultspeed \
         _sudo setup_sudolifetime \
         _pm _addrepo _pm_policy _pm_install _pm_update _pm_upgrade _pm_clean \
         setup_noversion \
         setup_arch \
         setup_local setup_localsrc setup_localsystemd \
         setup_polyglot setup_tpm setup_gittemplates \
         setup_gnomethemes setup_gnomeicons setup_gnomelocalicons \
         setup_dot setup_dot_vimrc setup_dot_tmuxconf setup_dot_tmuxintmuxconf setup_dot_bashrc setup_dot_profile \
         setup_dot_aliases setup_dot_gitignore setup_dot_hooks setup_dot_systemd

_git ()
{
  if git --git-dir "${setup_localsrc}/${1}/.git" --work-tree "${setup_localsrc}/"${*}
  then
    return 0
  else
    return 1
  fi
}

dashed ()
{
  set -- "${1}" "${setup_outputlen}" "${setup_rainbow}" ''
  while [ ${2} -gt 0 ]
  do
    [ -z "${3}" ] && set -- "${1}" "${2}" "${setup_rainbow}" "${4}"
    set -- "${1}" "$(( ${2} - 1 ))" "${3#*"${setup_sep}"}" "${4}${3%%"${setup_sep}"*}-"
  done
  set -- "${1}" "$(( ${#1} + 1 ))" "${4}"
  while [ ${2} -gt 0 ]
  do
    set -- "${1}" "$(( ${2} - 1 ))" "${3#*-}"
  done
  printf '%b%s%b %b%b ' "${setup_white}" "${1}" "${setup_reset}" "${3%\\*}" "${setup_reset}"
  return 0
}

# -- INPUT --
# 1) message
# 2) speed
dots ()
{
  trap 'setup_dotsbreak=""' USR1
  dashed "${1}"
  set -- "$(( $(date '+%s%N') * ${2} / setup_nanos ))" "${2}"
  set -- "${1}" "${@}"
  while [ -n "${setup_dotsbreak-x}" ]
  do
    set -- "${1}" "${2}" "${3}" "$(( $(date '+%s%N') * ${3} / setup_nanos ))"
    if [ $(( ${4} - ${1} )) -gt 0 ]
    then
      printf '%b%b.%b' "${setup_white}" "${setup_bold}" "${setup_reset}"
      set -- "$(( $(date '+%s%N') * ${3} / setup_nanos ))" "${2}" "${3}" "${4}"
    fi
    if [ $(( ${4} - ${2} )) -gt 3 ]
    then
      printf '%b%b' "${setup_movetocolx}" "${setup_eraseuntilend}"
      set -- "${1}" "$(( $(date '+%s%N') * ${3} / setup_nanos ))" "${3}" "${4}"
    fi
  done
  unset setup_dotsbreak
  return 0
}

stop_dots ()
{
  kill -USR1 "${1}"
  wait "${1}" || :
  printf '%b%b' "${setup_movetocolx}" "${setup_eraseuntilend}"
  return 0
}

prompt_sudo ()
{
  if [ $(( $(date '+%s') - ${setup_sudolastprompt:-"0"} )) -gt ${setup_sudolifetime} ]
  then
    sudo -k
    setup_sudolastprompt="$(date '+%s')"
    ${_sudo} sh -c ':' || exit 1
  fi
  return 0
}

success ()
{
  printf '%b%bOK%b\n' "${setup_green}" "${setup_bold}" "${setup_reset}"
  return 0
}

error ()
{
  printf '%b%bKO%b\n' "${setup_red}" "${setup_bold}" "${setup_reset}"
  return 0
}

run ()
{
  dots "${1}" "${setup_defaultspeed}" &
  shift
  while [ ${#} -gt 0 ]
  do
    if [ -n "${setup_needeval-}" ]
    then
      if [ "${setup_needeval%"${setup_needeval#?}"}" = "${setup_sep}" ]
      then
        setup_needeval="${setup_needeval#"${setup_sep}"}"
      else
        if ! eval "{ ${1}; } > /dev/null 2>&1"
        then
          stop_dots "${!}"
          error
          exit 1
        fi
        setup_needeval="${setup_needeval#*"${setup_sep}"}"
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
    dots "Checking ${1} package installation" "${setup_defaultspeed}" &
    if dpkg -l "${1}" > /dev/null 2>&1
    then
      stop_dots "${!}"
      success
    else
      stop_dots "${!}"
      error
      prompt_sudo
      run "Installing ${1} package" "${_pm_install} ${1}"
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
      | ${_sudo} gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    prompt_sudo
    printf 'deb [arch=%s signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu %s stable\n' "${setup_arch}" "${setup_release}" \
      | ${_sudo} tee /etc/apt/sources.list.d/docker.list > /dev/null
  fi

  if ! getent group docker > /dev/null
  then
    prompt_sudo
    run 'Adding new docker group' "${_sudo} groupadd docker"
  fi

  case "$(getent group docker):" in
    *:"${setup_user}":*) ;;
    *) prompt_sudo
       run 'Adding current user to docker group' "${_sudo} usermod -aG docker ${setup_user}" ;;
  esac

  return 0
}

git_install ()
{
  if [ ! -d "${setup_localsrc}/${1}" ]
  then
    setup_needeval= run "Cloning ${1} repository" "git clone ${2} ${setup_localsrc}/${1}"
    setup_needeval= run "Adding ${1} repository as a GIT safe repository" \
      "git config --global --add safe.directory ${setup_localsrc}/${1}"
    set -- '' '' '' '' "${@}"
  else
    setup_needeval= run "Adding ${1} repository as a GIT safe repository" \
      "git config --global --add safe.directory ${setup_localsrc}/${1}"
    setup_needeval="NEEDEVAL${setup_sep}" run \
      "Moving to master/main branch into ${1} repository" \
      "_git ${1} checkout master || _git ${1} checkout main"
    setup_needeval= run \
      "Checking ${1} remote and local master branches are Up-to-date" \
      "_git ${1} remote update"

    # $1=setup_local, $2=REMOTE, $3=BASE
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
      setup_needeval= run "Pulling ${1} repository" "_git ${1} pull"
      set -- "$(_git "${1}" rev-list --tags --max-count=1)" "${@}"
      set -- "$(_git "${2}" describe --tags "${1}" 2> /dev/null || :)" "${@}"
      if [ -n "${1}" ] && [ -z "${setup_notag+x}${setup_notag-}" ]
      then
        setup_needeval= run "Moving to ${1} tag into ${3} repository" \
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
      setup_needeval="${setup_needeval-}" run "${1}" "${2}"
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
    printf 'git %s' "${setup_noversion}"
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
    printf 'docker %s' "${setup_noversion}"
  fi
  return 0
}

version_direnv ()
{
  if [ -e "$(command -v direnv)" ] && [ -d "${setup_localsrc}/direnv" ]
  then
    set -- "$(_git direnv rev-list --tags --max-count=1)"
    set -- "$(_git direnv describe --tags "${1}")"
    set -- "${1#"${1%%[[:digit:]]*}"}"
    set -- "${1%"${1##[[:digit:]]*}"}"
    printf 'direnv %s' "${1}"
  else
    printf 'direnv %s' "${setup_noversion}"
  fi
  return 0
}

version_vim ()
{
  if [ -e "$(command -v vim)" ] && [ -d "${setup_localsrc}/vim" ]
  then
    set -- "$(_git vim rev-list --tags --max-count=1)"
    set -- "$(_git vim describe --tags "${1}")"
    set -- "${1#"${1%%[[:digit:]]*}"}"
    set -- "${1%"${1##[[:digit:]]*}"}"
    printf 'vim %s' "${1}"
  else
    printf 'vim %s' "${setup_noversion}"
  fi
  return 0
}

version_tig ()
{
  if [ -e "$(command -v tig)" ]
  then
    set -- "${IFS}"
    IFS="${setup_newline}"
    set -- "${1}" $(tig --version)
    IFS="${1}"
    set -- "${2#"${2%%[[:digit:]]*}"}"
    printf 'tig %s' "${1}"
  else
    printf 'tig %s' "${setup_noversion}"
  fi
  return 0
}

version_shellcheck ()
{
  if [ -e "$(command -v shellcheck)" ]
  then
    set -- "${IFS}"
    IFS="${setup_newline}"
    set -- "${1}" $(shellcheck --version)
    IFS="${1}"
    set -- "${3#"${3%%[[:digit:]]*}"}"
    printf 'shellcheck %s' "${1}"
  else
    printf 'shellcheck %s' "${setup_noversion}"
  fi
  return 0
}

version_fff ()
{
  if [ -e "$(command -v fff)" ]
  then
    fff -v | tr -d '\n'
  else
    printf 'fff %s' "${setup_noversion}"
  fi
  return 0
}

version_tmux ()
{
  if [ -e "$(command -v tmux)" ]
  then
    tmux -V | tr -d '\n'
  else
    printf 'tmux %s' "${setup_noversion}"
  fi
  return 0
}

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

version_linguist ()
{
  if [ -e "$(command -v github-linguist)" ]
  then
    set -- "$(github-linguist --version)"
    set -- "${1#"${1%%[[:digit:]]*}"}"
    printf 'linguist %s' "${1}"
  else
    printf 'linguist %s' "${setup_noversion}"
  fi
  return 0
}

version_polyglot ()
{
  if [ -d "${setup_localsrc}/polyglot" ] && [ -d "${setup_polyglot}" ]
  then
    set -- "$(_git polyglot rev-list --tags --max-count=1)"
    set -- "$(_git polyglot describe --tags "${1}")"
    set -- "${1#"${1%%[[:digit:]]*}"}"
    set -- "${1%"${1##[[:digit:]]*}"}"
    printf 'polyglot %s' "${1}"
  else
    printf 'polyglot %s' "${setup_noversion}"
  fi
  return 0
}

version_tpm ()
{
  if [ -d "${setup_localsrc}/tpm" ]
  then
    set -- "$(_git tpm rev-list --tags --max-count=1)"
    set -- "$(_git tpm describe --tags "${1}")"
    set -- "${1#"${1%%[[:digit:]]*}"}"
    set -- "${1%"${1##[[:digit:]]*}"}"
    printf 'tpm %s' "${1}"
  else
    printf 'tpm %s' "${setup_noversion}"
  fi
  return 0
}

version_chromethemes ()
{
  if [ -d "${setup_localsrc}/chromethemes" ]
  then
    printf 'chromethemes 0'
  else
    printf 'chromethemes %s' "${setup_noversion}"
  fi
  return 0
}

version_candyicons ()
{
  if [ -d "${setup_localsrc}/candyicons" ]
  then
    printf 'candyicons 0'
  else
    printf 'candyicons %s' "${setup_noversion}"
  fi
  return 0
}

version_sweetfolders ()
{
  if [ -d "${setup_localsrc}/sweetfolders" ]
  then
    printf 'sweetfolders 0'
  else
    printf 'sweetfolders %s' "${setup_noversion}"
  fi
  return 0
}

version_bananacursor ()
{
  if [ -d "${setup_localsrc}/bananacursor" ]
  then
    set -- "$(_git bananacursor rev-list --tags --max-count=1)"
    set -- "$(_git bananacursor describe --tags "${1}")"
    set -- "${1#"${1%%[[:digit:]]*}"}"
    set -- "${1%"${1##[[:digit:]]*}"}"
    printf 'bananacursor %s' "${1}"
  else
    printf 'bananacursor %s' "${setup_noversion}"
  fi
  return 0
}

version_fonts ()
{
  if [ -d "${setup_localsrc}/fonts" ]
  then
    set -- "$(_git fonts rev-list --tags --max-count=1)"
    set -- "$(_git fonts describe --tags "${1}")"
    set -- "${1#"${1%%[[:digit:]]*}"}"
    set -- "${1%"${1##[[:digit:]]*}"}"
    printf 'fonts %s' "${1}"
  else
    printf 'fonts %s' "${setup_noversion}"
  fi
  return 0
}

sumup ()
{
  printf '\n'
  while [ -n "${1}" ]
  do
    case "${1%%"${setup_sep}"*}" in
      *"${setup_noversion}"*) printf '%b' "${setup_blue}" ;;
      *) if [ "${1%%"${setup_sep}"*}" != "$(eval "version_${1%%[[:space:]]*}")" ]
         then
           printf '%b' "${setup_green2}"
         else
           printf '%b' "${setup_white}"
         fi ;;
    esac
    printf '%b%s -> ' "${setup_bold}" "${1%%"${setup_sep}"*}"
    eval "version_${1%%[[:space:]]*}"
    set -- "${1#*"${setup_sep}"}"
    printf '%b\n' "${setup_reset}"
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

  mkdir -p "${setup_local}/bin" "${setup_local}/share" "${setup_local}/lib" "${setup_localsrc}" \
    "${setup_localsystemd}" "${setup_polyglot}" "${setup_tpm}" "${setup_gnomethemes}" \
    "${setup_gnomeicons}"

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
    run 'Disabling bluetooth service' "${_sudo} systemctl disable bluetooth.service" \
      '/lib/systemd/systemd-sysv-install disable bluetooth'
  else
    error
    return 1
  fi

  if ! command -v lsb_release > /dev/null
  then
    prompt_sudo
    run 'Updating system' "${_pm_update}"
    install lsb-release
  fi

  setup_release="$(lsb_release -cs)"
  readonly setup_release

  dashed 'Checking mesa drivers ppa'
  case "${setup_release}" in
    focal) setup_pparepo='kisak/kisak-mesa' ;;
    jammy) setup_pparepo='oibaf/graphics-drivers' ;;
    *) error
       printf 'Unknown %s release\n' "${setup_release}" 1>&2
       return 1 ;;
  esac
  case "$(${_pm_policy} 2> /dev/null)" in
    *"${setup_pparepo}"*) success ;;
    *) error
       set -f
       run 'Adding mesa drivers ppa' "${_sudo} ${_addrepo} ppa:${setup_pparepo}"
       set +f ;;
  esac

  dashed 'Checking git ppa'
  setup_pparepo='git-core/ppa'
  case "$(${_pm_policy} 2> /dev/null)" in
    *"${setup_pparepo}"*) success ;;
    *) error
       set -f
       run 'Adding git-core ppa' "${_sudo} ${_addrepo} ppa:${setup_pparepo}"
       set +f ;;
  esac

  set -- "${1}" "${2}$(version_git)${setup_sep}"
  set -- "${1}" "${2}$(version_docker)${setup_sep}"
  set -- "${1}" "${2}$(version_direnv)${setup_sep}"
  set -- "${1}" "${2}$(version_vim)${setup_sep}"
  set -- "${1}" "${2}$(version_tig)${setup_sep}"
  set -- "${1}" "${2}$(version_shellcheck)${setup_sep}"
  set -- "${1}" "${2}$(version_fff)${setup_sep}"
  set -- "${1}" "${2}$(version_tmux)${setup_sep}"
  set -- "${1}" "${2}$(version_pass)${setup_sep}"
  set -- "${1}" "${2}$(version_linguist)${setup_sep}"
  set -- "${1}" "${2}$(version_polyglot)${setup_sep}"
  set -- "${1}" "${2}$(version_chromethemes)${setup_sep}"
  set -- "${1}" "${2}$(version_candyicons)${setup_sep}"
  set -- "${1}" "${2}$(version_sweetfolders)${setup_sep}"
  set -- "${1}" "${2}$(version_bananacursor)${setup_sep}"
  set -- "${1}" "${2}$(version_fonts)${setup_sep}"

  prompt_sudo
  run 'Updating system' "${_pm_update}"

  prompt_sudo
  run 'Upgrading system' "${_pm_upgrade}"

  prompt_sudo
  run 'Removing unused packages' "${_pm_clean}"

  # for CLI
  install git tree curl jq silversearcher-ag build-essential make autoconf \
    automake cmake kcolorchooser libreoffice-gnome libreoffice gnome-tweaks \
    gnome-shell-extensions dbus-x11 vulkan-tools

  # for GNOME extensions and themes
  install gtk2-engines-murrine gtk2-engines-pixbuf

  # for spaceporn
  install libpng-dev libvulkan-dev vulkan-validationlayers-dev spirv-tools \
    libglfw3-dev libxxf86vm-dev libxi-dev imagemagick dconf-cli

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
  IFS="${setup_newline}"
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
    "${_sudo} ln -f -s $(command -v gcc-10) $(command -v gcc)" \
    "${_sudo} ln -f -s $(command -v g++-10) $(command -v g++)"

  install_docker

  # for docker
  install docker-ce docker-ce-cli containerd.io docker-compose-plugin

  setup_needeval="NEEDEVAL${setup_sep}" git_install 'direnv' \
    'https://github.com/direnv/direnv' 'Installing direnv' \
    "cd ${setup_localsrc}/direnv && sudo bash install.sh && cd -"
  git_install 'vim' 'https://github.com/vim/vim' 'Compiling vim' \
    "make --directory ${setup_localsrc}/vim" 'Installing vim' \
    "${_sudo} make --directory ${setup_localsrc}/vim install"
  git_install 'tig' 'https://github.com/jonas/tig' 'Compiling tig' \
    "make --directory ${setup_localsrc}/tig clean all prefix=${setup_local}" \
    'Installing tig' \
    "make --directory ${setup_localsrc}/tig install prefix=${setup_local}" \
    'Documenting tig' \
    "${_sudo} make --directory ${setup_localsrc}/tig install-doc prefix=/usr"
  setup_needeval="NEEDEVAL${setup_sep}" git_install 'shellcheck' \
    'https://github.com/koalaman/shellcheck' 'Installing shellcheck' \
    "cd ${setup_localsrc}/shellcheck && cabal install --overwrite-policy=always --installdir=${HOME}/.cabal/bin && cd -"
  setup_notag='true' git_install 'fff' 'https://github.com/dylanaraps/fff' \
    'Installing fff' "make --directory ${setup_localsrc}/fff PREFIX=${setup_local} install"
  setup_needeval="NEEDEVAL${setup_sep}NEEDEVAL${setup_sep}${setup_sep}${setup_sep}" git_install 'tmux' \
    'https://github.com/tmux/tmux' 'Generating tmux configuration' \
    "cd ${setup_localsrc}/tmux && sh autogen.sh && cd -" 'Configuring tmux' \
    "cd ${setup_localsrc}/tmux && ./configure && cd -" 'Compiling tmux' \
    "make --directory ${setup_localsrc}/tmux" 'Installing tmux' \
    "${_sudo} make --directory ${setup_localsrc}/tmux install"
  setup_notag='true' git_install 'pass' 'https://git.zx2c4.com/password-store' \
    'Installing password-store' \
    "${_sudo} make install --directory ${setup_localsrc}/pass"
  setup_needeval="NEEDEVAL${setup_sep}" git_install 'linguist' \
    'https://github.com/github/linguist' 'Installing/Updating github-linguist' \
    "if command -v github-linguist; then ${_sudo} gem update github-linguist; else ${_sudo} gem install github-linguist; fi"
  setup_needeval="NEEDEVAL${setup_sep}" setup_notag='true' git_install \
    'fonts' 'https://github.com/powerline/fonts' \
    'Installing powerline fonts' "cd ${setup_localsrc}/fonts && ./install.sh"

  run 'Copying .vimrc' "cp -f ${setup_dot_vimrc} ${HOME}"

  setup_needeval="NEEDEVAL${setup_sep}" setup_notag='true' git_install 'polyglot' \
    'https://github.com/sheerun/vim-polyglot' \
    'Copying polyglot to vim plugins directory' \
    "(set -- ${setup_localsrc}/polyglot/*;"' while [ ${#} -gt 0 ]; do case "${1}" in *.git) ;; *) cp -a -f "${1}"'" ${setup_polyglot} ;; esac; shift; done)"

  run 'Copying .tmux.conf' "cp -f ${setup_dot_tmuxconf} ${HOME}"
  run 'Copying .tmuxintmux.conf' "cp -f ${setup_dot_tmuxintmuxconf} ${HOME}"

  setup_needeval="NEEDEVAL${setup_sep}" setup_notag='true' git_install 'tpm' 'https://github.com/tmux-plugins/tpm' \
    'Copying tpm into .tmux directory' \
    "(set -- ${setup_localsrc}/tpm/*;"' while [ ${#} -gt 0 ]; do case "${1}" in *.git) ;; *) cp -a "${1}"'" ${setup_tpm} ;; esac; shift; done)"

  run 'Installing tmux plugins' "${setup_tpm}/bin/install_plugins"

  setup_needeval="${setup_sep}NEEDEVAL${setup_sep}" run 'Copying .bashrc' \
    "cp -f /etc/skel/.bashrc ${HOME}" \
    "cat ${setup_dot_bashrc} >> ${HOME}/.bashrc"

  setup_needeval="${setup_sep}NEEDEVAL${setup_sep}" run 'Copying .profile' \
    "cp -f /etc/skel/.profile ${HOME}/.profile" \
    "cat ${setup_dot_profile} >> ${HOME}/.profile"

  run 'Copying .bash_aliases' "cp -f ${setup_dot_aliases} ${HOME}/.bash_aliases"

  prompt_sudo
  run 'Copying .gitignore' "sudo cp -f ${setup_dot_gitignore} ${setup_gittemplates}"

  prompt_sudo
  run 'Copying hooks' "sudo cp -a -f ${setup_dot_hooks} ${setup_gittemplates}"

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

      setup_needeval="NEEDEVAL${setup_sep}" run 'Changing terminal font to Powerline font' \
        "dconf write \"/org/gnome/terminal/legacy/profiles:/\$(dconf list /org/gnome/terminal/legacy/profiles:/)font\" \"'Ubuntu Mono derivative Powerline 13'\""

      setup_notag='true' git_install 'chromethemes' 'https://github.com/rtlewis1/GTK' \
        'Moving to Chrome OS themes branch' \
        '_git chromethemes checkout remotes/origin/ChromeOS-Dark' \
        'Copying UltraViolet theme' \
        "cp -a -f ${setup_localsrc}/chromethemes/ChromeOS-Darker-UltraViolet-Rounded ${setup_gnomethemes}"

      setup_notag='true' git_install 'candyicons' \
        'https://github.com/EliverLara/candy-icons' 'Copying candy icons' \
        "cp -a -f ${setup_localsrc}/candyicons ${setup_gnomeicons}" \
        'Creating candy-link symbolic link' \
        "ln -s -f ${setup_gnomeicons}/candyicons ${setup_gnomeicons}/candy-icons"

      setup_notag='true' git_install 'sweetfolders' \
        'https://github.com/EliverLara/Sweet-folders' 'Copying sweet folders' \
        "cp -a -f ${setup_localsrc}/sweetfolders ${setup_gnomelocalicons}"

      setup_url="$(curl -s https://api.github.com/repos/ful1e5/banana-cursor/releases/latest \
        | jq -r '.assets[] | select(.name | test("tar.gz")) | .browser_download_url')"
      readonly setup_url

      git_install 'bananacursor' 'https://github.com/ful1e5/banana-cursor' \
        'Download banana cursor archive' \
        "curl -L ${setup_url} --output ${setup_gnomeicons}/Banana.tar.gz" \
        'Unarchive the banana cursor' \
        "tar xf ${setup_gnomeicons}/Banana.tar.gz -C ${setup_gnomeicons}" \
        'Removing archives' "rm -f ${setup_gnomeicons}/Banana.tar.gz"

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

      run 'Deploy systemd timers' "cp -f ${setup_dot_systemd}/* ${setup_localsystemd}" \
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

main "${@}"
