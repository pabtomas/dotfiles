#!/bin/bash

function dashed () {
  echo -e "$1 $(printf "%$(( 68 - ${#1} ))s" | tr ' ' '-' )"
}

function dots () {
  local -r CLEAR="\e[K"
  local START=$(($(date +%s) + 1))
  while [ 1 ]; do
    printf '.%.0s' $(seq 0 1 $((($(date +%s) - ${START}) % 3)) ) \
      | xargs -I {} echo -n -e ${CLEAR}"$1 "{}$'\r' && sleep 0.2
  done
}

function main () {
  sudo -k && sudo echo &> /dev/null && local SUDO_START=$(date +%s)

  local -r CLEAR="\e[K"
  local -r GREEN=$(tput setaf 2)
  local -r RED=$(tput setaf 9)
  local -r RESET=$(tput sgr0)
  local -r CLONE_DIR="/tmp/repositories_clone"
  local -r BACKUP="$(pwd)"
  local -r SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
  local -r VIMRC="${SCRIPT_DIR}/vim/.vimrc"
  local -r TMUXCONF="${SCRIPT_DIR}/tmux/.tmux.conf"
  local -r BASIC_BASHRC="${SCRIPT_DIR}/bash/.bashrc/basic_settings"
  local -r GUI_BASHRC="${SCRIPT_DIR}/bash/.bashrc/gui_settings"
  local -r PROFILE="${SCRIPT_DIR}/bash/.bash_profile"
  local -r ALIASES="${SCRIPT_DIR}/bash/.bash_aliases/usual"
  local -r GITIGNORE="${SCRIPT_DIR}/git/.gitignore"
  local -r HOOKS="${SCRIPT_DIR}/git/.hooks"
  local -r AUTOSTART_SCRIPTS="${SCRIPT_DIR}/autostart/scripts"
  local -r DESKTOP="${SCRIPT_DIR}/autostart/desktop"
  local -r EXECUTOR_SCRIPTS="${SCRIPT_DIR}/executor/scripts"
  local -r SCHEMA="${SCRIPT_DIR}/executor/schema/org.gnome.shell.extensions.executor.gschema.xml "
  local -r TPM_DEST="${HOME}/.tmux/plugins/tpm"
  local -r EXECUTOR_DEST="${HOME}/.local/share/gnome-shell/extensions/executor@raujonas.github.io/"
  local -r EXECUTOR_REPO="https://github.com/raujonas/executor.git"
  local -r GIT_TEMPLATE_DIR="/usr/share/git-core/templates"
  local GNOME=1
  local DASHED=""
  local DOTS_PID=0
  local STATUS=0
  local GPU=""

  echo -n -e $(dashed "Checking apt installation")$' '
  if [ $(which apt | wc -l) -gt 0 ]; then
    echo -e ${GREEN}"OK"${RESET}
  else
    echo -e ${RED}"Not OK"${RESET} && return 1
  fi

  echo -n -e $(dashed "Checking GNOME installation")$' '
  if [ $(echo "${XDG_CURRENT_DESKTOP}" | grep -E -i "GNOME" | wc -l) -gt 0 ] \
    && [ $(which gnome-shell | wc -l) -gt 0 ]; then
      echo -e ${GREEN}"OK"${RESET}
  else
    echo -e ${RED}"Not OK"${RESET} && GNOME=0
  fi

  if [ ${GNOME} -eq 1 ]; then
    echo -n -e $(dashed "Checking GNOME version")$' '
    if [ $(echo -e $(gnome-shell --version | sed "s/^[^0-9]\+//")"\n3.30.1" \
      | sort -V | head -n1) == "3.30.1" ]; then
        echo -e ${GREEN}"OK"${RESET}
    else
      echo -e ${RED}"Not OK"${RESET} \
        && echo -e "\n$(gnome-shell --version)\n" && GNOME=0
    fi
  fi

  echo -n -e $(dashed "Checking bluetooth service")$' '
  if [ -f /etc/init.d/bluetooth ]; then
    echo -e ${GREEN}"OK"${RESET}
    DASHED=$(dashed "Disabling bluetooth")
    [ $(( $(date +%s) - ${SUDO_START} )) -gt 290 ] && sudo -k \
      && sudo echo &> /dev/null && SUDO_START=$(date +%s)
    dots "${DASHED}" &
    DOTS_PID=$!
    sudo systemctl disable bluetooth.service &> /dev/null
    STATUS=$?

    kill ${DOTS_PID} &> /dev/null
    wait ${DOTS_PID} &> /dev/null
    DASHED=${CLEAR}${DASHED}

    if [ ${STATUS} -eq 0 ]; then
      echo -e ${DASHED} ${GREEN}"OK"${RESET}
    else
      echo -e ${DASHED} ${RED}"Not OK"${RESET} \
        && command cd ${BACKUP} && return 1
    fi
  else
    echo -e ${RED}"Not OK"${RESET}
  fi

  echo -n -e $(dashed "Checking unbuffer installation")$' '
  if [ $(which unbuffer | wc -l) -eq 0 ]; then
    echo -e ${RED}"Not OK"${RESET}
    DASHED=$(dashed "Installing expect-dev package")
    [ $(( $(date +%s) - ${SUDO_START} )) -gt 290 ] && sudo -k \
      && sudo echo &> /dev/null && SUDO_START=$(date +%s)
    dots "${DASHED}" &
    DOTS_PID=$!
    sudo apt install -y expect-dev &> /dev/null
    STATUS=$?

    kill ${DOTS_PID} &> /dev/null
    wait ${DOTS_PID} &> /dev/null
    DASHED=${CLEAR}${DASHED}

    if [ ${STATUS} -eq 0 ]; then
      echo -e ${DASHED} ${GREEN}"OK"${RESET}
    else
      echo -e ${DASHED} ${RED}"Not OK"${RESET} \
        && command cd ${BACKUP} && return 1
    fi
  else
    echo -e ${GREEN}"OK"${RESET}
  fi

  DASHED=${CLEAR}$(dashed "Updating system")
  [ $(( $(date +%s) - ${SUDO_START} )) -gt 290 ] && sudo -k \
    && sudo echo &> /dev/null && SUDO_START=$(date +%s)
  sudo unbuffer apt update -y | unbuffer -p grep -E -o "[0-9]+%" \
    | xargs -I {} echo -n -e ${DASHED} {}

  if [ $? -eq 0 ]; then
    echo -e ${DASHED} ${GREEN}"OK"${RESET}
  else
    echo -e ${DASHED} ${RED}"Not OK"${RESET} && return 1
  fi

  DASHED=${CLEAR}$(dashed "Upgrading system")
  [ $(( $(date +%s) - ${SUDO_START} )) -gt 290 ] && sudo -k \
    && sudo echo &> /dev/null && SUDO_START=$(date +%s)
  sudo unbuffer apt upgrade -y | unbuffer -p grep -E -o "[0-9]+%" \
    | xargs -I {} echo -n -e ${DASHED} {}

  if [ $? -eq 0 ]; then
    echo -e ${DASHED} ${GREEN}"OK"${RESET}
  else
    echo -e ${DASHED} ${RED}"Not OK"${RESET} && return 1
  fi

  DASHED=${CLEAR}$(dashed "Removing unused packages")
  [ $(( $(date +%s) - ${SUDO_START} )) -gt 290 ] && sudo -k \
    && sudo echo &> /dev/null && SUDO_START=$(date +%s)
  sudo unbuffer apt autoremove -y | unbuffer -p grep -E -o "[0-9]+%" \
    | xargs -I {} echo -n -e ${DASHED} {}

  if [ $? -eq 0 ]; then
    echo -e ${DASHED} ${GREEN}"OK"${RESET}
  else
    echo -e ${DASHED} ${RED}"Not OK"${RESET} && return 1
  fi

  echo -n -e $(dashed "Checking GIT installation")$' '
  if [ $(which git | wc -l) -eq 0 ]; then
    echo -e ${RED}"Not OK"${RESET}
    DASHED=${CLEAR}$(dashed "Installing GIT package")
    [ $(( $(date +%s) - ${SUDO_START} )) -gt 290 ] && sudo -k \
      && sudo echo &> /dev/null && SUDO_START=$(date +%s)
    sudo unbuffer apt install -y git | unbuffer -p grep -E -o "[0-9]+%" \
      | xargs -I {} echo -n -e ${DASHED} {}

    if [ $? -eq 0 ]; then
      echo -e ${DASHED} ${GREEN}"OK"${RESET}
    else
      echo -e ${DASHED} ${RED}"Not OK"${RESET} && return 1
    fi
  else
    echo -e ${GREEN}"OK"${RESET}
  fi

  echo -n -e $(dashed "Checking libncurses-dev installation")$' '
  if [ $(dpkg -l | command grep -E "libncurses-dev" | wc -l) -eq 0 ]; then
    echo -e ${RED}"Not OK"${RESET}
    DASHED=${CLEAR}$(dashed "Installing libncurses-dev package")
    [ $(( $(date +%s) - ${SUDO_START} )) -gt 290 ] && sudo -k \
      && sudo echo &> /dev/null && SUDO_START=$(date +%s)
    sudo unbuffer apt install -y libncurses-dev \
      | unbuffer -p grep -E -o "[0-9]+%" | xargs -I {} echo -n -e ${DASHED} {}

    if [ $? -eq 0 ]; then
      echo -e ${DASHED} ${GREEN}"OK"${RESET}
    else
      echo -e ${DASHED} ${RED}"Not OK"${RESET} && return 1
    fi
  else
    echo -e ${GREEN}"OK"${RESET}
  fi

  echo -n -e $(dashed "Checking libevent-dev installation")$' '
  if [ $(dpkg -l | command grep -E "libevent-dev" | wc -l) -eq 0 ]; then
    echo -e ${RED}"Not OK"${RESET}
    DASHED=${CLEAR}$(dashed "Installing libevent-dev package")
    [ $(( $(date +%s) - ${SUDO_START} )) -gt 290 ] && sudo -k \
      && sudo echo &> /dev/null && SUDO_START=$(date +%s)
    sudo unbuffer apt install -y libevent-dev \
      | unbuffer -p grep -E -o "[0-9]+%" | xargs -I {} echo -n -e ${DASHED} {}

    if [ $? -eq 0 ]; then
      echo -e ${DASHED} ${GREEN}"OK"${RESET}
    else
      echo -e ${DASHED} ${RED}"Not OK"${RESET} && return 1
    fi
  else
    echo -e ${GREEN}"OK"${RESET}
  fi

  echo -n -e $(dashed "Checking gcc installation")$' '
  if [ $(which gcc | wc -l) -eq 0 ]; then
    echo -e ${RED}"Not OK"${RESET}
    DASHED=${CLEAR}$(dashed "Installing build-essential package")
    [ $(( $(date +%s) - ${SUDO_START} )) -gt 290 ] && sudo -k \
      && sudo echo &> /dev/null && SUDO_START=$(date +%s)
    sudo unbuffer apt install -y build-essential \
      | unbuffer -p grep -E -o "[0-9]+%" | xargs -I {} echo -n -e ${DASHED} {}

    if [ $? -eq 0 ]; then
      echo -e ${DASHED} ${GREEN}"OK"${RESET}
    else
      echo -e ${DASHED} ${RED}"Not OK"${RESET} && return 1
    fi
  else
    echo -e ${GREEN}"OK"${RESET}
  fi

  echo -n -e $(dashed "Checking yacc installation")$' '
  if [ $(which yacc | wc -l) -eq 0 ]; then
    echo -e ${RED}"Not OK"${RESET}
    DASHED=${CLEAR}$(dashed "Installing bison package")
    [ $(( $(date +%s) - ${SUDO_START} )) -gt 290 ] && sudo -k \
      && sudo echo &> /dev/null && SUDO_START=$(date +%s)
    sudo unbuffer apt install -y bison | unbuffer -p grep -E -o "[0-9]+%" \
      | xargs -I {} echo -n -e ${DASHED} {}

    if [ $? -eq 0 ]; then
      echo -e ${DASHED} ${GREEN}"OK"${RESET}
    else
      echo -e ${DASHED} ${RED}"Not OK"${RESET} && return 1
    fi
  else
    echo -e ${GREEN}"OK"${RESET}
  fi

  echo -n -e $(dashed "Checking make installation")$' '
  if [ $(which make | wc -l) -eq 0 ]; then
    echo -e ${RED}"Not OK"${RESET}
    DASHED=${CLEAR}$(dashed "Installing make package")
    [ $(( $(date +%s) - ${SUDO_START} )) -gt 290 ] && sudo -k \
      && sudo echo &> /dev/null && SUDO_START=$(date +%s)
    sudo unbuffer apt install -y make | unbuffer -p grep -E -o "[0-9]+%" \
      | xargs -I {} echo -n -e ${DASHED} {}

    if [ $? -eq 0 ]; then
      echo -e ${DASHED} ${GREEN}"OK"${RESET}
    else
      echo -e ${DASHED} ${RED}"Not OK"${RESET} && return 1
    fi
  else
    echo -e ${GREEN}"OK"${RESET}
  fi

  echo -n -e $(dashed "Checking automake installation")$' '
  if [ $(dpkg -l | command grep -E "automake" | wc -l) -eq 0 ]; then
    echo -e ${RED}"Not OK"${RESET}
    DASHED=${CLEAR}$(dashed "Installing automake package")
    [ $(( $(date +%s) - ${SUDO_START} )) -gt 290 ] && sudo -k \
      && sudo echo &> /dev/null && SUDO_START=$(date +%s)
    sudo unbuffer apt install -y automake | unbuffer -p grep -E -o "[0-9]+%" \
      | xargs -I {} echo -n -e ${DASHED} {}

    if [ $? -eq 0 ]; then
      echo -e ${DASHED} ${GREEN}"OK"${RESET}
    else
      echo -e ${DASHED} ${RED}"Not OK"${RESET} && return 1
    fi
  else
    echo -e ${GREEN}"OK"${RESET}
  fi

  echo -n -e $(dashed "Checking autoconf installation")$' '
  if [ $(dpkg -l | command grep -E "autoconf" | wc -l) -eq 0 ]; then
    echo -e ${RED}"Not OK"${RESET}
    DASHED=${CLEAR}$(dashed "Installing autoconf package")
    [ $(( $(date +%s) - ${SUDO_START} )) -gt 290 ] && sudo -k \
      && sudo echo &> /dev/null && SUDO_START=$(date +%s)
    sudo unbuffer apt install -y autoconf | unbuffer -p grep -E -o "[0-9]+%" \
      | xargs -I {} echo -n -e ${DASHED} {}

    if [ $? -eq 0 ]; then
      echo -e ${DASHED} ${GREEN}"OK"${RESET}
    else
      echo -e ${DASHED} ${RED}"Not OK"${RESET} && return 1
    fi
  else
    echo -e ${GREEN}"OK"${RESET}
  fi

  echo -n -e $(dashed "Checking pkg-config installation")$' '
  if [ $(dpkg -l | command grep -E "pkg-config" | wc -l) -eq 0 ]; then
    echo -e ${RED}"Not OK"${RESET}
    DASHED=${CLEAR}$(dashed "Installing pkg-config package")
    [ $(( $(date +%s) - ${SUDO_START} )) -gt 290 ] && sudo -k \
      && sudo echo &> /dev/null && SUDO_START=$(date +%s)
    sudo unbuffer apt install -y pkg-config \
      | unbuffer -p grep -E -o "[0-9]+%" | xargs -I {} echo -n -e ${DASHED} {}

    if [ $? -eq 0 ]; then
      echo -e ${DASHED} ${GREEN}"OK"${RESET}
    else
      echo -e ${DASHED} ${RED}"Not OK"${RESET} && return 1
    fi
  else
    echo -e ${GREEN}"OK"${RESET}
  fi

  if [ ${GNOME} -eq 1 ]; then
    echo -n -e $(dashed "Checking glxinfo installation")$' '
    if [ $(which glxinfo | wc -l) -eq 0 ]; then
      echo -e ${RED}"Not OK"${RESET}
      DASHED=${CLEAR}$(dashed "Installing mesa-utils package")
      [ $(( $(date +%s) - ${SUDO_START} )) -gt 290 ] && sudo -k \
        && sudo echo &> /dev/null && SUDO_START=$(date +%s)
      sudo unbuffer apt install -y mesa-utils \
        | unbuffer -p grep -E -o "[0-9]+%" \
        | xargs -I {} echo -n -e ${DASHED} {}
      if [ $? -eq 0 ]; then
        echo -e ${DASHED} ${GREEN}"OK"${RESET}
      else
        echo -e ${DASHED} ${RED}"Not OK"${RESET} && return 1
      fi
    else
      echo -e ${GREEN}"OK"${RESET}
    fi

    echo -n -e $(dashed "Checking X-server reachability")$' '
    if [ $(glxinfo | grep -E -i "Device" | wc -l) -eq 0 ]; then
      echo -e ${RED}"Not OK"${RESET}
    else
      echo -e ${GREEN}"OK"${RESET}
      GPU=$(glxinfo | grep -E -i "Device")
      echo -e "\n${GPU}\n"

      if [ $(echo ${GPU} | grep -E -i "Intel" | wc -l) -eq 1 ]; then
        echo -n -e $(dashed "Checking intel_gpu_top installation")$' '
        if [ $(which intel_gpu_top | wc -l) -eq 0 ]; then
          echo -e ${RED}"Not OK"${RESET}
          DASHED=${CLEAR}$(dashed "Installing intel-gpu-tools package")
          [ $(( $(date +%s) - ${SUDO_START} )) -gt 290 ] && sudo -k \
            && sudo echo &> /dev/null && SUDO_START=$(date +%s)
          sudo unbuffer apt install -y intel-gpu-tools \
            | unbuffer -p grep -E -o "[0-9]+%" \
            | xargs -I {} echo -n -e ${DASHED} {}

          if [ $? -eq 0 ]; then
            echo -e ${DASHED} ${GREEN}"OK"${RESET}
          else
            echo -e ${DASHED} ${RED}"Not OK"${RESET} && return 1
          fi
        else
          echo -e ${GREEN}"OK"${RESET}
        fi

        echo -n -e $(dashed "Checking intel_gpu_top usage")$' '
        [ $(( $(date +%s) - ${SUDO_START} )) -gt 290 ] && sudo -k \
          && sudo echo &> /dev/null && SUDO_START=$(date +%s)
        if [ $(sudo \cat /etc/sudoers | grep -E "intel_gpu_top" | wc -l) -eq 0 ]; then
          echo -e ${RED}"Not OK"${RESET}
          DASHED=${CLEAR}$(dashed "Modifying intel_gpu_top usage")
          dots "${DASHED}" &
          DOTS_PID=$!
          echo "$(whoami) ALL = NOPASSWD: $(which intel_gpu_top)" \
            | sudo EDITOR='tee -a' visudo &> /dev/null
          STATUS=$?

          kill ${DOTS_PID} &> /dev/null
          wait ${DOTS_PID} &> /dev/null
          DASHED=${CLEAR}${DASHED}

          if [ ${STATUS} -eq 0 ]; then
            echo -e ${DASHED} ${GREEN}"OK"${RESET}
          else
            echo -e ${DASHED} ${RED}"Not OK"${RESET} && command cd ${BACKUP} \
              && sudo \rm -rf ${CLONE_DIR} && return 1
          fi
        else
          echo -e ${GREEN}"OK"${RESET}
        fi

        echo -n -e $(dashed "Checking redshift installation")$' '
        if [ $(which redshift | wc -l) -eq 0 ]; then
          echo -e ${RED}"Not OK"${RESET}
          DASHED=${CLEAR}$(dashed "Installing redshift package")
          [ $(( $(date +%s) - ${SUDO_START} )) -gt 290 ] && sudo -k \
            && sudo echo &> /dev/null && SUDO_START=$(date +%s)
          sudo unbuffer apt install -y redshift \
            | unbuffer -p grep -E -o "[0-9]+%" \
            | xargs -I {} echo -n -e ${DASHED} {}

          if [ $? -eq 0 ]; then
            echo -e ${DASHED} ${GREEN}"OK"${RESET}
          else
            echo -e ${DASHED} ${RED}"Not OK"${RESET} && return 1
          fi
        else
          echo -e ${GREEN}"OK"${RESET}
        fi

        echo -n -e $(dashed "Checking jq installation")$' '
        if [ $(which jq | wc -l) -eq 0 ]; then
          echo -e ${RED}"Not OK"${RESET}
          DASHED=${CLEAR}$(dashed "Installing jq package")
          [ $(( $(date +%s) - ${SUDO_START} )) -gt 290 ] && sudo -k \
            && sudo echo &> /dev/null && SUDO_START=$(date +%s)
          sudo unbuffer apt install -y jq | unbuffer -p grep -E -o "[0-9]+%" \
            | xargs -I {} echo -n -e ${DASHED} {}

          if [ $? -eq 0 ]; then
            echo -e ${DASHED} ${GREEN}"OK"${RESET}
          else
            echo -e ${DASHED} ${RED}"Not OK"${RESET} && return 1
          fi
        else
          echo -e ${GREEN}"OK"${RESET}
        fi
      fi
    fi
  fi

  echo -n -e $(dashed "Checking VIM version")$' '
  if [ $(which vim | wc -l) -eq 1 ]; then
    echo -e ${GREEN}"OK"${RESET}
    echo -e "\n    vim "$(echo $(vim --version | head -n 2 | grep -E -o \
      " [0-9]+\.[0-9]+ |[0-9]+$") | tr ' ' '.')"\n"
  else
    echo -e ${RED}"Not OK"${RESET}
  fi

  [ $(( $(date +%s) - ${SUDO_START} )) -gt 290 ] && sudo -k \
    && sudo echo &> /dev/null && SUDO_START=$(date +%s)
  [ -d ${CLONE_DIR} ] && sudo \rm -rf ${CLONE_DIR}
  command mkdir -p ${CLONE_DIR}

  DASHED=${CLEAR}$(dashed "Cloning VIM repository")
  unbuffer git clone https://github.com/vim/vim.git ${CLONE_DIR}/vim \
    | unbuffer -p grep -E -o "[0-9]+%" | xargs -I {} echo -n -e ${DASHED} {}
  if [ $? -eq 0 ]; then
    echo -e ${DASHED} ${GREEN}"OK"${RESET}
  else
    echo -e ${DASHED} ${RED}"Not OK"${RESET} \
      && sudo \rm -rf ${CLONE_DIR} && return 1
  fi

  command cd ${CLONE_DIR}/vim/src

  DASHED=$(dashed "Configuring VIM")
  [ $(( $(date +%s) - ${SUDO_START} )) -gt 290 ] && sudo -k \
    && sudo echo &> /dev/null && SUDO_START=$(date +%s)
  dots "${DASHED}" &
  DOTS_PID=$!
  ${CLONE_DIR}/vim/src/configure &> /dev/null
  STATUS=$?

  kill ${DOTS_PID} &> /dev/null
  wait ${DOTS_PID} &> /dev/null
  DASHED=${CLEAR}${DASHED}

  if [ ${STATUS} -eq 0 ]; then
    echo -e ${DASHED} ${GREEN}"OK"${RESET}
  else
    echo -e ${DASHED} ${RED}"Not OK"${RESET} && command cd ${BACKUP} \
      && sudo \rm -rf ${CLONE_DIR} && return 1
  fi

  DASHED=$(dashed "Compiling VIM")
  [ $(( $(date +%s) - ${SUDO_START} )) -gt 290 ] && sudo -k \
    && sudo echo &> /dev/null && SUDO_START=$(date +%s)
  dots "${DASHED}" &
  DOTS_PID=$!
  make &> /dev/null
  STATUS=$?

  kill ${DOTS_PID} &> /dev/null
  wait ${DOTS_PID} &> /dev/null
  DASHED=${CLEAR}${DASHED}

  if [ ${STATUS} -eq 0 ]; then
    echo -e ${DASHED} ${GREEN}"OK"${RESET}
  else
    echo -e ${DASHED} ${RED}"Not OK"${RESET} && command cd ${BACKUP} \
      && sudo \rm -rf ${CLONE_DIR} && return 1
  fi

  DASHED=$(dashed "Installing VIM")
  [ $(( $(date +%s) - ${SUDO_START} )) -gt 290 ] && sudo -k \
    && sudo echo &> /dev/null && SUDO_START=$(date +%s)
  dots "${DASHED}" &
  DOTS_PID=$!
  sudo make install &> /dev/null
  STATUS=$?

  kill ${DOTS_PID} &> /dev/null
  wait ${DOTS_PID} &> /dev/null
  DASHED=${CLEAR}${DASHED}

  if [ ${STATUS} -eq 0 ]; then
    echo -e ${DASHED} ${GREEN}"OK"${RESET}
  else
    echo -e ${DASHED} ${RED}"Not OK"${RESET} && command cd ${BACKUP} \
      && sudo \rm -rf ${CLONE_DIR} && return 1
  fi

  echo -e "\n    vim "$(echo $(vim --version | head -n 2 | grep -E -o \
    " [0-9]+\.[0-9]+ |[0-9]+$") | tr ' ' '.')"\n"

  echo -n -e $(dashed "Checking TMUX version")$' '
  if [ $(which tmux | wc -l) -eq 1 ]; then
    echo -e ${GREEN}"OK"${RESET}
    echo -e "\n    $(tmux -V)\n"
  else
    echo -e ${RED}"Not OK"${RESET}
  fi

  DASHED=${CLEAR}$(dashed "Cloning TMUX repository")
  [ $(( $(date +%s) - ${SUDO_START} )) -gt 290 ] && sudo -k \
    && sudo echo &> /dev/null && SUDO_START=$(date +%s)
  unbuffer git clone https://github.com/tmux/tmux.git ${CLONE_DIR}/tmux \
    | unbuffer -p grep -E -o "[0-9]+%" | xargs -I {} echo -n -e ${DASHED} {}

  if [ $? -eq 0 ]; then
    echo -e ${DASHED} ${GREEN}"OK"${RESET}
  else
    echo -e ${DASHED} ${RED}"Not OK"${RESET} && command cd ${BACKUP} \
      && sudo \rm -rf ${CLONE_DIR} && return 1
  fi

  DASHED=$(dashed "Configuring TMUX")
  [ $(( $(date +%s) - ${SUDO_START} )) -gt 290 ] && sudo -k \
    && sudo echo &> /dev/null && SUDO_START=$(date +%s)
  dots "${DASHED}" &
  DOTS_PID=$!
  command cd ${CLONE_DIR}/tmux && sh ${CLONE_DIR}/tmux/autogen.sh \
    &> /dev/null && ${CLONE_DIR}/tmux/configure &> /dev/null
  STATUS=$?

  kill ${DOTS_PID} &> /dev/null
  wait ${DOTS_PID} &> /dev/null
  DASHED=${CLEAR}${DASHED}

  if [ ${STATUS} -eq 0 ]; then
    echo -e ${DASHED} ${GREEN}"OK"${RESET}
  else
    echo -e ${DASHED} ${RED}"Not OK"${RESET} && command cd ${BACKUP} \
      && sudo \rm -rf ${CLONE_DIR} && return 1
  fi

  DASHED=$(dashed "Compiling TMUX")
  [ $(( $(date +%s) - ${SUDO_START} )) -gt 290 ] && sudo -k \
    && sudo echo &> /dev/null && SUDO_START=$(date +%s)
  dots "${DASHED}" &
  DOTS_PID=$!
  make &> /dev/null
  STATUS=$?

  kill ${DOTS_PID} &> /dev/null
  wait ${DOTS_PID} &> /dev/null
  DASHED=${CLEAR}${DASHED}

  if [ ${STATUS} -eq 0 ]; then
    echo -e ${DASHED} ${GREEN}"OK"${RESET}
  else
    echo -e ${DASHED} ${RED}"Not OK"${RESET} && command cd ${BACKUP} \
      && sudo \rm -rf ${CLONE_DIR} && return 1
  fi

  DASHED=$(dashed "Installing TMUX")
  [ $(( $(date +%s) - ${SUDO_START} )) -gt 290 ] && sudo -k \
    && sudo echo &> /dev/null && SUDO_START=$(date +%s)
  dots "${DASHED}" &
  DOTS_PID=$!
  sudo make install &> /dev/null
  STATUS=$?

  kill ${DOTS_PID} &> /dev/null
  wait ${DOTS_PID} &> /dev/null
  DASHED=${CLEAR}${DASHED}

  if [ ${STATUS} -eq 0 ]; then
    echo -e ${DASHED} ${GREEN}"OK"${RESET}
  else
    echo -e ${DASHED} ${RED}"Not OK"${RESET} && command cd ${BACKUP} \
      && sudo \rm -rf ${CLONE_DIR} && return 1
  fi

  echo -e "\n    $(tmux -V)\n"

  [ $(( $(date +%s) - ${SUDO_START} )) -gt 290 ] && sudo -k \
    && sudo echo &> /dev/null && SUDO_START=$(date +%s)
  command cd ${SCRIPT_DIR} && sudo \rm -rf ${CLONE_DIR}

  DASHED=${CLEAR}$(dashed "Cloning TMUX Plugin Manager repository")
  [ $(( $(date +%s) - ${SUDO_START} )) -gt 290 ] && sudo -k \
    && sudo echo &> /dev/null && SUDO_START=$(date +%s)
  [ -d ${TPM_DEST} ] && sudo \rm -rf ${TPM_DEST}
  unbuffer git clone https://github.com/tmux-plugins/tpm ${TPM_DEST} \
    | unbuffer -p grep -E -o "[0-9]+%" | xargs -I {} echo -n -e ${DASHED} {}

  if [ $? -eq 0 ]; then
    echo -e ${DASHED} ${GREEN}"OK"${RESET}
  else
    echo -e ${DASHED} ${RED}"Not OK"${RESET} && command cd ${BACKUP} \
      && return 1
  fi

  if [ ${GNOME} -eq 1 ]; then
    DASHED=${CLEAR}$(dashed "Cloning EXECUTOR repository")
    [ $(( $(date +%s) - ${SUDO_START} )) -gt 290 ] && sudo -k \
      && sudo echo &> /dev/null && SUDO_START=$(date +%s)
    [ -d ${EXECUTOR_DEST} ] && sudo \rm -rf ${EXECUTOR_DEST}
    sudo unbuffer git clone ${EXECUTOR_REPO} ${EXECUTOR_DEST} \
      | unbuffer -p grep -E -o "[0-9]+%" | xargs -I {} echo -n -e ${DASHED} {}

    if [ $? -eq 0 ]; then
      echo -e ${DASHED} ${GREEN}"OK"${RESET}
    else
      echo -e ${DASHED} ${RED}"Not OK"${RESET} && command cd ${BACKUP} \
        && return 1
    fi
  fi

  DASHED=$(dashed "Copying .vimrc")
  dots "${DASHED}" &
  DOTS_PID=$!
  command cp ${VIMRC} ${HOME} &> /dev/null
  STATUS=$?

  kill ${DOTS_PID} &> /dev/null
  wait ${DOTS_PID} &> /dev/null
  DASHED=${CLEAR}${DASHED}

  if [ ${STATUS} -eq 0 ]; then
    echo -e ${DASHED} ${GREEN}"OK"${RESET}
  else
    echo -e ${DASHED} ${RED}"Not OK"${RESET} && command cd ${BACKUP} \
      && return 1
  fi

  DASHED=$(dashed "Copying .tmux.conf")
  dots "${DASHED}" &
  DOTS_PID=$!
  command cp ${TMUXCONF} ${HOME} &> /dev/null
  STATUS=$?

  kill ${DOTS_PID} &> /dev/null
  wait ${DOTS_PID} &> /dev/null
  DASHED=${CLEAR}${DASHED}

  if [ ${STATUS} -eq 0 ]; then
    echo -e ${DASHED} ${GREEN}"OK"${RESET}
  else
    echo -e ${DASHED} ${RED}"Not OK"${RESET} && command cd ${BACKUP} \
      && return 1
  fi

  DASHED=$(dashed "Installing TMUX Plugins")
  dots "${DASHED}" &
  DOTS_PID=$!
  ${HOME}/.tmux/plugins/tpm/bin/install_plugins &> /dev/null
  STATUS=$?

  kill ${DOTS_PID} &> /dev/null
  wait ${DOTS_PID} &> /dev/null
  DASHED=${CLEAR}${DASHED}

  if [ ${STATUS} -eq 0 ]; then
    echo -e ${DASHED} ${GREEN}"OK"${RESET}
  else
    echo -e ${DASHED} ${RED}"Not OK"${RESET} && command cd ${BACKUP} \
      && return 1
  fi

  DASHED=$(dashed "Copying .bashrc")
  dots "${DASHED}" &
  DOTS_PID=$!
  command cp /etc/skel/.bashrc ${HOME} &> /dev/null \
    && echo -e "\n$(cat ${BASIC_BASHRC})" >> ${HOME}/.bashrc

  if [ $? -ne 0 ]; then
    kill ${DOTS_PID} &> /dev/null
    wait ${DOTS_PID} &> /dev/null
    DASHED=${CLEAR}${DASHED}
    echo -e ${DASHED} ${RED}"Not OK"${RESET} && command cd ${BACKUP} \
      && return 1
  else
    if [ ${GNOME} -eq 1 ]; then
      echo -e "\n$(cat ${GUI_BASHRC})" >> ${HOME}/.bashrc
      STATUS=$?
      kill ${DOTS_PID} &> /dev/null
      wait ${DOTS_PID} &> /dev/null
      DASHED=${CLEAR}${DASHED}
      if [ ${STATUS} -eq 0 ]; then
        echo -e ${DASHED} ${GREEN}"OK"${RESET}
      else
        echo -e ${DASHED} ${RED}"Not OK"${RESET} \
          && command cd ${BACKUP} && return 1
      fi
    else
      kill ${DOTS_PID} &> /dev/null
      wait ${DOTS_PID} &> /dev/null
      DASHED=${CLEAR}${DASHED}
      echo -e ${DASHED} ${GREEN}"OK"${RESET}
    fi
  fi

  DASHED=$(dashed "Copying .bash_profile")
  dots "${DASHED}" &
  DOTS_PID=$!
  command cp ${PROFILE} ${HOME} &> /dev/null
  STATUS=$?

  kill ${DOTS_PID} &> /dev/null
  wait ${DOTS_PID} &> /dev/null
  DASHED=${CLEAR}${DASHED}

  if [ ${STATUS} -eq 0 ]; then
    echo -e ${DASHED} ${GREEN}"OK"${RESET}
  else
    echo -e ${DASHED} ${RED}"Not OK"${RESET} && command cd ${BACKUP} \
      && return 1
  fi

  DASHED=$(dashed "Copying .bash_aliases")
  dots "${DASHED}" &
  DOTS_PID=$!
  command cp ${ALIASES} ${HOME}/.bash_aliases &> /dev/null
  STATUS=$?

  kill ${DOTS_PID} &> /dev/null
  wait ${DOTS_PID} &> /dev/null
  DASHED=${CLEAR}${DASHED}

  if [ ${STATUS} -eq 0 ]; then
    echo -e ${DASHED} ${GREEN}"OK"${RESET}
  else
    echo -e ${DASHED} ${RED}"Not OK"${RESET} && command cd ${BACKUP} \
      && return 1
  fi

  DASHED=$(dashed "Copying .gitignore")
  [ $(( $(date +%s) - ${SUDO_START} )) -gt 290 ] && sudo -k \
    && sudo echo &> /dev/null && SUDO_START=$(date +%s)
  dots "${DASHED}" &
  DOTS_PID=$!
  sudo \cp ${GITIGNORE} ${GIT_TEMPLATE_DIR} &> /dev/null
  STATUS=$?

  kill ${DOTS_PID} &> /dev/null
  wait ${DOTS_PID} &> /dev/null
  DASHED=${CLEAR}${DASHED}

  if [ ${STATUS} -eq 0 ]; then
    echo -e ${DASHED} ${GREEN}"OK"${RESET}
  else
    echo -e ${DASHED} ${RED}"Not OK"${RESET} && command cd ${BACKUP} \
      && return 1
  fi

  DASHED=$(dashed "Copying GIT hooks")
  [ $(( $(date +%s) - ${SUDO_START} )) -gt 290 ] && sudo -k \
    && sudo echo &> /dev/null && SUDO_START=$(date +%s)
  dots "${DASHED}" &
  DOTS_PID=$!
  sudo \cp -r ${HOOKS} ${GIT_TEMPLATE_DIR} &> /dev/null
  STATUS=$?

  kill ${DOTS_PID} &> /dev/null
  wait ${DOTS_PID} &> /dev/null
  DASHED=${CLEAR}${DASHED}

  if [ ${STATUS} -eq 0 ]; then
    echo -e ${DASHED} ${GREEN}"OK"${RESET}
  else
    echo -e ${DASHED} ${RED}"Not OK"${RESET} && command cd ${BACKUP} \
      && return 1
  fi

  if [ ${GNOME} -eq 1 ]; then
    DASHED=$(dashed "Copying EXECUTOR scripts")
    [ $(( $(date +%s) - ${SUDO_START} )) -gt 290 ] && sudo -k \
      && sudo echo &> /dev/null && SUDO_START=$(date +%s)
    dots "${DASHED}" &
    DOTS_PID=$!
    [ -d ${HOME}/.executor ] && sudo \rm -rf ${HOME}/.executor
    command cp -r ${EXECUTOR_SCRIPTS} ${HOME}/.executor &> /dev/null
    STATUS=$?

    kill ${DOTS_PID} &> /dev/null
    wait ${DOTS_PID} &> /dev/null
    DASHED=${CLEAR}${DASHED}

    if [ ${STATUS} -eq 0 ]; then
      echo -e ${DASHED} ${GREEN}"OK"${RESET}
    else
      echo -e ${DASHED} ${RED}"Not OK"${RESET} \
        && command cd ${BACKUP} && return 1
    fi

    DASHED=$(dashed "Copying EXECUTOR schema")
    [ $(( $(date +%s) - ${SUDO_START} )) -gt 290 ] && sudo -k \
      && sudo echo &> /dev/null && SUDO_START=$(date +%s)
    dots "${DASHED}" &
    DOTS_PID=$!
    sudo \cp ${SCHEMA} ${EXECUTOR_DEST}/schemas
    STATUS=$?

    kill ${DOTS_PID} &> /dev/null
    wait ${DOTS_PID} &> /dev/null
    DASHED=${CLEAR}${DASHED}

    if [ ${STATUS} -eq 0 ]; then
      echo -e ${DASHED} ${GREEN}"OK"${RESET}
    else
      echo -e ${DASHED} ${RED}"Not OK"${RESET} \
        && command cd ${BACKUP} && return 1
    fi

    DASHED=$(dashed "Copying autostart scripts")
    [ $(( $(date +%s) - ${SUDO_START} )) -gt 290 ] && sudo -k \
      && sudo echo &> /dev/null && SUDO_START=$(date +%s)
    dots "${DASHED}" &
    DOTS_PID=$!
    for SCRIPT in $(command ls ${AUTOSTART_SCRIPTS}); do
      sudo \cp ${AUTOSTART_SCRIPTS}/${SCRIPT} /usr/bin &> /dev/null
    done
    STATUS=$?

    kill ${DOTS_PID} &> /dev/null
    wait ${DOTS_PID} &> /dev/null
    DASHED=${CLEAR}${DASHED}

    if [ ${STATUS} -eq 0 ]; then
      echo -e ${DASHED} ${GREEN}"OK"${RESET}
    else
      echo -e ${DASHED} ${RED}"Not OK"${RESET} \
        && command cd ${BACKUP} && return 1
    fi

    DASHED=$(dashed "Copying desktop entries")
    dots "${DASHED}" &
    DOTS_PID=$!
    command rm -r ${HOME}/.config/autostart/*
    for ENTRY in $(command ls ${DESKTOP}); do
      command cp ${DESKTOP}/${ENTRY} ${HOME}/.config/autostart &> /dev/null
    done
    STATUS=$?

    kill ${DOTS_PID} &> /dev/null
    wait ${DOTS_PID} &> /dev/null
    DASHED=${CLEAR}${DASHED}

    if [ ${STATUS} -eq 0 ]; then
      echo -e ${DASHED} ${GREEN}"OK"${RESET}
    else
      echo -e ${DASHED} ${RED}"Not OK"${RESET} \
        && command cd ${BACKUP} && return 1
    fi

    DASHED=$(dashed "Enabling GNOME extensions")
    dots "${DASHED}" &
    DOTS_PID=$!
    gsettings set org.gnome.shell disable-user-extensions false &> /dev/null
    STATUS=$?

    kill ${DOTS_PID} &> /dev/null
    wait ${DOTS_PID} &> /dev/null
    DASHED=${CLEAR}${DASHED}

    if [ ${STATUS} -eq 0 ]; then
      echo -e ${DASHED} ${GREEN}"OK"${RESET}
    else
      echo -e ${DASHED} ${RED}"Not OK"${RESET} \
        && command cd ${BACKUP} && return 1
    fi

    DASHED=$(dashed "Compiling EXECUTOR schema")
    [ $(( $(date +%s) - ${SUDO_START} )) -gt 290 ] && sudo -k \
      && sudo echo &> /dev/null && SUDO_START=$(date +%s)
    DOTS_PID=$!
    sudo glib-compile-schemas ${EXECUTOR_DEST}/schemas &> /dev/null \
      && dconf reset -f /org/gnome/shell/extensions/executor &> /dev/null
    STATUS=$?

    kill ${DOTS_PID} &> /dev/null
    wait ${DOTS_PID} &> /dev/null
    DASHED=${CLEAR}${DASHED}

    if [ ${STATUS} -eq 0 ]; then
      echo -e ${DASHED} ${GREEN}"OK"${RESET}
    else
      echo -e ${DASHED} ${RED}"Not OK"${RESET} \
        && command cd ${BACKUP} && return 1
    fi

    DASHED=$(dashed "Enabling EXECUTOR")
    dots "${DASHED}" &
    DOTS_PID=$!
    gnome-extensions enable executor@raujonas.github.io &> /dev/null
    STATUS=$?

    kill ${DOTS_PID} &> /dev/null
    wait ${DOTS_PID} &> /dev/null
    DASHED=${CLEAR}${DASHED}

    if [ ${STATUS} -eq 0 ]; then
      echo -e ${DASHED} ${GREEN}"OK"${RESET}
    else
      echo -e ${DASHED} ${RED}"Not OK"${RESET} \
        && command cd ${BACKUP} && return 1
    fi

    DASHED=$(dashed "Hidding desktop icons")
    dots "${DASHED}" &
    DOTS_PID=$!
    gsettings set org.gnome.desktop.background show-desktop-icons false \
      &> /dev/null

    STATUS=$?

    kill ${DOTS_PID} &> /dev/null
    wait ${DOTS_PID} &> /dev/null
    DASHED=${CLEAR}${DASHED}

    if [ ${STATUS} -eq 0 ]; then
      echo -e ${DASHED} ${GREEN}"OK"${RESET}
    else
      echo -e ${DASHED} ${RED}"Not OK"${RESET}
    fi

    if [ $(gnome-extensions list | grep -E "desktop-icons" | wc -l) -eq 1 ];
      then
        DASHED=$(dashed "Disabling desktop-icons extension")
        dots "${DASHED}" &
        DOTS_PID=$!
        gsettings set org.gnome.shell.extensions.desktop-icons show-home \
          false &> /dev/null && gsettings set \
            org.gnome.shell.extensions.desktop-icons show-trash false \
              &> /dev/null && gnome-extensions disable desktop-icons@csoriano \
                &> /dev/null
        STATUS=$?

        kill ${DOTS_PID} &> /dev/null
        wait ${DOTS_PID} &> /dev/null
        DASHED=${CLEAR}${DASHED}

        if [ ${STATUS} -eq 0 ]; then
          echo -e ${DASHED} ${GREEN}"OK"${RESET}
        else
          echo -e ${DASHED} ${RED}"Not OK"${RESET}
        fi
    fi

    DASHED=$(dashed "Setting GNOME Interface")
    dots "${DASHED}" &
    DOTS_PID=$!
    gsettings set org.gnome.desktop.interface show-battery-percentage true \
      &> /dev/null && [ -f /etc/X11/cursors/redglass.theme ] \
      && gsettings set org.gnome.desktop.interface cursor-theme 'redglass' \
        &> /dev/null && [ -d /usr/share/icons/HighContrast ] \
      && gsettings set org.gnome.desktop.interface gtk-theme \
        'HighContrastInverse' &> /dev/null

    STATUS=$?

    kill ${DOTS_PID} &> /dev/null
    wait ${DOTS_PID} &> /dev/null
    DASHED=${CLEAR}${DASHED}

    if [ ${STATUS} -eq 0 ]; then
      echo -e ${DASHED} ${GREEN}"OK"${RESET}
    else
      echo -e ${DASHED} ${RED}"Not OK"${RESET}
    fi

    DASHED=$(dashed "Restarting GNOME")
    echo -n -e "${DASHED}"$' '
    killall -3 gnome-shell &> /dev/null

    if [ $? -eq 0 ]; then
      echo -n -e ${GREEN}"OK"${RESET}\
        "\n\n    Press Enter when GNOME service is functional again " \
          && read && echo
    else
      echo -e ${RED}"Not OK"${RESET} && command cd ${BACKUP} && return 1
    fi
  fi

  DASHED=$(dashed "Sourcing .bashrc")
  dots "${DASHED}" &
  DOTS_PID=$!
  source ${HOME}/.bashrc &> /dev/null
  STATUS=$?

  kill ${DOTS_PID} &> /dev/null
  wait ${DOTS_PID} &> /dev/null
  DASHED=${CLEAR}${DASHED}

  if [ ${STATUS} -eq 0 ]; then
    echo -e ${DASHED} ${GREEN}"OK"${RESET}
  else
    echo -e ${DASHED} ${RED}"Not OK"${RESET} && command cd ${BACKUP} \
      && return 1
  fi

  command cd ${BACKUP}
}

(return 0 2>/dev/null)
[ $? -ne 0 ] && echo "This script has to be sourced." && exit 1
main
unset -f dots
unset -f dashed
unset -f main
