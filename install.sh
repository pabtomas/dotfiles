#!/bin/bash

(return 0 2>/dev/null)
[ $? -ne 0 ] && echo "This script has to be sourced." && exit 1
sudo -k && sudo echo &> /dev/null

CLEAR="\e[K"

function chrono () {
  trap 'exit 0' TERM
  local START=$(($(date +%s) + 1))
  while [ 1 ]; do
    echo -n -e ${CLEAR}"$1" \
      && printf '.%.0s' $(seq 0 1 $((($(date +%s) - ${START}) % 3)) ) \
      && echo -n -e $'\r' && sleep 0.2
  done
}

echo -n "Checking apt installation ---------------------------------------- "
if [ $(which apt | wc -l) -gt 0 ]; then
  echo -e $(tput setaf 2)"OK   "$(tput sgr0)
else
  echo -e $(tput setaf 9)"Not OK"$(tput sgr0) && return 1
fi

GNOME=1

echo -n "Checking GNOME installation -------------------------------------- "
if [ $(echo "${XDG_CURRENT_DESKTOP}" | grep -E "GNOME" | wc -l) -gt 0 ] \
  && [ $(which gnome-shell | wc -l) -gt 0 ]; then
    echo -e $(tput setaf 2)"OK   "$(tput sgr0)
else
  echo -e $(tput setaf 9)"Not OK"$(tput sgr0) && GNOME=0
fi

if [ ${GNOME} -eq 1 ]; then
  echo -n "Checking GNOME version ------------------------------------------- "
  if [ $(echo -e $(gnome-shell --version | sed "s/^[^0-9]\+//")"\n3.30.1" \
    | sort -V | head -n1) == "3.30.1" ]; then
      echo -e $(tput setaf 2)"OK   "$(tput sgr0)
  else
    echo -e $(tput setaf 9)"Not OK"$(tput sgr0) \
      && echo -e "\n$(gnome-shell --version)\n" && GNOME=0
  fi
fi

echo -n "Checking bluetooth service --------------------------------------- "
if [ -f /etc/init.d/bluetooth ]; then
  echo -e $(tput setaf 2)"OK   "$(tput sgr0)
  chrono "Disabling bluetooth ---------------------------------------------- " &
  CHRONO_PID=$!
  sudo systemctl disable bluetooth.service &> /dev/null
  STATUS=$?

  pkill $(ps -q ${CHRONO_PID} -o comm=)
  wait ${CHRONO_PID} &> /dev/null && echo -n -e ${CLEAR}

  if [ ${STATUS} -eq 0 ]; then
    echo -e "Disabling bluetooth ---------------------------------------------- "$(tput setaf 2)"OK   "$(tput sgr0)
  else
    echo -e "Disabling bluetooth ---------------------------------------------- "$(tput setaf 9)"Not OK"$(tput sgr0) \
      && command cd ${BACKUP} && return 1
  fi
else
  echo -e $(tput setaf 9)"Not OK"$(tput sgr0)
fi

CLONE_DIR=/tmp/repositories_clone
BACKUP=$(pwd)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

echo -n "Checking unbuffer installation ----------------------------------- "
if [ $(which unbuffer | wc -l) -eq 0 ]; then
  echo -e $(tput setaf 9)"Not OK"$(tput sgr0)
  echo -n "Installing expect-dev package ------------------------------------ "
  sudo apt install -y expect-dev &> /dev/null \
    && echo -e $(tput setaf 2)"OK   "$(tput sgr0)
else
  echo -e $(tput setaf 2)"OK   "$(tput sgr0)
fi

sudo unbuffer apt update -y | unbuffer -p grep -E -o "[0-9]+%" \
  | xargs -I {} echo -n -e ${CLEAR}"Updating system -------------------------------------------------- {}" \
  && echo -e ${CLEAR}"Updating system -------------------------------------------------- "$(tput setaf 2)"OK   "$(tput sgr0)

[ $? -ne 0 ] && echo -e ${CLEAR}"Updating system -------------------------------------------------- "$(tput setaf 9)"Not OK"$(tput sgr0) && return 1

sudo unbuffer apt upgrade -y | unbuffer -p grep -E -o "[0-9]+%" \
  | xargs -I {} echo -n -e ${CLEAR}"Upgrading system ------------------------------------------------- {}" \
  && echo -e ${CLEAR}"Upgrading system ------------------------------------------------- "$(tput setaf 2)"OK   "$(tput sgr0)

[ $? -ne 0 ] && echo -e ${CLEAR}"Upgrading system ------------------------------------------------- "$(tput setaf 9)"Not OK"$(tput sgr0) && return 1

sudo unbuffer apt autoremove -y | unbuffer -p grep -E -o "[0-9]+%" \
  | xargs -I {} echo -n -e ${CLEAR}"Removing unused packages ----------------------------------------- {}" \
  && echo -e ${CLEAR}"Removing unused packages ----------------------------------------- "$(tput setaf 2)"OK   "$(tput sgr0)

[ $? -ne 0 ] && echo -e ${CLEAR}"Removing unused packages ----------------------------------------- "$(tput setaf 9)"Not OK"$(tput sgr0) && return 1

echo -n "Checking GIT installation ---------------------------------------- "
if [ $(which git | wc -l) -eq 0 ]; then
  echo -e $(tput setaf 9)"Not OK"$(tput sgr0)
  sudo unbuffer apt install -y git | unbuffer -p grep -E -o "[0-9]+%" \
    | xargs -I {} echo -n -e ${CLEAR}"Installing GIT package ------------------------------------------- {}" \
    && echo -e ${CLEAR}"Installing GIT package ------------------------------------------- "$(tput setaf 2)"OK   "$(tput sgr0)
else
  echo -e $(tput setaf 2)"OK   "$(tput sgr0)
fi

[ $? -ne 0 ] && echo -e ${CLEAR}"Installing GIT package ------------------------------------------- "$(tput setaf 9)"Not OK"$(tput sgr0) && return 1

echo -n "Checking libncurses-dev installation ----------------------------- "
if [ $(dpkg -l | command grep -E "libncurses-dev" | wc -l) -eq 0 ]; then
  echo -e $(tput setaf 9)"Not OK"$(tput sgr0)
  sudo unbuffer apt install -y libncurses-dev | unbuffer -p grep -E -o "[0-9]+%" \
    | xargs -I {} echo -n -e ${CLEAR}"Installing libncurses-dev package -------------------------------- {}" \
    && echo -e ${CLEAR}"Installing libncurses-dev package -------------------------------- "$(tput setaf 2)"OK   "$(tput sgr0)
else
  echo -e $(tput setaf 2)"OK   "$(tput sgr0)
fi

[ $? -ne 0 ] && echo -e ${CLEAR}"Installing libncurses-dev package -------------------------------- "$(tput setaf 9)"Not OK"$(tput sgr0) && return 1

echo -n "Checking libevent-dev installation ------------------------------- "
if [ $(dpkg -l | command grep -E "libevent-dev" | wc -l) -eq 0 ]; then
  echo -e $(tput setaf 9)"Not OK"$(tput sgr0)
  sudo unbuffer apt install -y libevent-dev | unbuffer -p grep -E -o "[0-9]+%" \
    | xargs -I {} echo -n -e ${CLEAR}"Installing libevent-dev package ---------------------------------- {}" \
    && echo -e ${CLEAR}"Installing libevent-dev package ---------------------------------- "$(tput setaf 2)"OK   "$(tput sgr0)
else
  echo -e $(tput setaf 2)"OK   "$(tput sgr0)
fi

[ $? -ne 0 ] && echo -e ${CLEAR}"Installing libevent-dev package ---------------------------------- "$(tput setaf 9)"Not OK"$(tput sgr0) && return 1

echo -n "Checking gcc installation ---------------------------------------- "
if [ $(which gcc | wc -l) -eq 0 ]; then
  echo -e $(tput setaf 9)"Not OK"$(tput sgr0)
  sudo unbuffer apt install -y build-essential \
    | unbuffer -p grep -E -o "[0-9]+%" \
    | xargs -I {} echo -n -e ${CLEAR}"Installing build-essential package ------------------------------- {}" \
    && echo -e ${CLEAR}"Installing build-essential package ------------------------------- "$(tput setaf 2)"OK   "$(tput sgr0)
else
  echo -e $(tput setaf 2)"OK   "$(tput sgr0)
fi

[ $? -ne 0 ] && echo -e ${CLEAR}"Installing build-essential package ------------------------------- "$(tput setaf 9)"Not OK"$(tput sgr0) && return 1

echo -n "Checking yacc installation --------------------------------------- "
if [ $(which yacc | wc -l) -eq 0 ]; then
  echo -e $(tput setaf 9)"Not OK"$(tput sgr0)
  sudo unbuffer apt install -y bison | unbuffer -p grep -E -o "[0-9]+%" \
    | xargs -I {} echo -n -e ${CLEAR}"Installing bison package ----------------------------------------- {}" \
    && echo -e ${CLEAR}"Installing bison package ----------------------------------------- "$(tput setaf 2)"OK   "$(tput sgr0)
else
  echo -e $(tput setaf 2)"OK   "$(tput sgr0)
fi

[ $? -ne 0 ] && echo -e ${CLEAR}"Installing bison package ----------------------------------------- "$(tput setaf 9)"Not OK"$(tput sgr0) && return 1

echo -n "Checking make installation --------------------------------------- "
if [ $(which make | wc -l) -eq 0 ]; then
  echo -e $(tput setaf 9)"Not OK"$(tput sgr0)
  sudo unbuffer apt install -y make | unbuffer -p grep -E -o "[0-9]+%" \
    | xargs -I {} echo -n -e ${CLEAR}"Installing make package ------------------------------------------ {}" \
    && echo -e ${CLEAR}"Installing make package ------------------------------------------ "$(tput setaf 2)"OK   "$(tput sgr0)
else
  echo -e $(tput setaf 2)"OK   "$(tput sgr0)
fi

[ $? -ne 0 ] && echo -e ${CLEAR}"Installing make package ------------------------------------------ "$(tput setaf 9)"Not OK"$(tput sgr0) && return 1

echo -n "Checking automake installation ----------------------------------- "
if [ $(dpkg -l | command grep -E "automake" | wc -l) -eq 0 ]; then
  echo -e $(tput setaf 9)"Not OK"$(tput sgr0)
  sudo unbuffer apt install -y automake | unbuffer -p grep -E -o "[0-9]+%" \
    | xargs -I {} echo -n -e ${CLEAR}"Installing automake package -------------------------------------- {}" \
    && echo -e ${CLEAR}"Installing automake package -------------------------------------- "$(tput setaf 2)"OK   "$(tput sgr0)
else
  echo -e $(tput setaf 2)"OK   "$(tput sgr0)
fi

[ $? -ne 0 ] && echo -e ${CLEAR}"Installing automake package -------------------------------------- "$(tput setaf 9)"Not OK"$(tput sgr0) && return 1

echo -n "Checking autoconf installation ----------------------------------- "
if [ $(dpkg -l | command grep -E "autoconf" | wc -l) -eq 0 ]; then
  echo -e $(tput setaf 9)"Not OK"$(tput sgr0)
  sudo unbuffer apt install -y autoconf | unbuffer -p grep -E -o "[0-9]+%" \
    | xargs -I {} echo -n -e ${CLEAR}"Installing autoconf package -------------------------------------- {}" \
    && echo -e ${CLEAR}"Installing autoconf package -------------------------------------- "$(tput setaf 2)"OK   "$(tput sgr0)
else
  echo -e $(tput setaf 2)"OK   "$(tput sgr0)
fi

[ $? -ne 0 ] && echo -e ${CLEAR}"Installing autoconf package -------------------------------------- "$(tput setaf 9)"Not OK"$(tput sgr0) && return 1

echo -n "Checking pkg-config installation --------------------------------- "
if [ $(dpkg -l | command grep -E "pkg-config" | wc -l) -eq 0 ]; then
  echo -e $(tput setaf 9)"Not OK"$(tput sgr0)
  sudo unbuffer apt install -y pkg-config | unbuffer -p grep -E -o "[0-9]+%" \
    | xargs -I {} echo -n -e ${CLEAR}"Installing pkg-config package ------------------------------------ {}" \
    && echo -e ${CLEAR}"Installing pkg-config package ------------------------------------ "$(tput setaf 2)"OK   "$(tput sgr0)
else
  echo -e $(tput setaf 2)"OK   "$(tput sgr0)
fi

[ $? -ne 0 ] && echo -e ${CLEAR}"Installing pkg-config package ------------------------------------ "$(tput setaf 9)"Not OK"$(tput sgr0) && return 1

if [ ${GNOME} -eq 1 ]; then
  echo -n "Checking redshift installation ----------------------------------- "
  if [ $(which redshift | wc -l) -eq 0 ]; then
    echo -e $(tput setaf 9)"Not OK"$(tput sgr0)
    sudo unbuffer apt install -y redshift | unbuffer -p grep -E -o "[0-9]+%" \
      | xargs -I {} echo -n -e ${CLEAR}"Installing redshift package -------------------------------------- {}" \
      && echo -e ${CLEAR}"Installing redshift package -------------------------------------- "$(tput setaf 2)"OK   "$(tput sgr0)
  else
    echo -e $(tput setaf 2)"OK   "$(tput sgr0)
  fi

  [ $? -ne 0 ] && echo -e ${CLEAR}"Installing redshift package -------------------------------------- "$(tput setaf 9)"Not OK"$(tput sgr0) && return 1
fi

echo -n "Checking VIM version --------------------------------------------- "
if [ $(which vim | wc -l) -eq 1 ]; then
  echo -e $(tput setaf 2)"OK   "$(tput sgr0)
  echo -e "\nvim "$(vim --version | head -n 2 | sed "s/^[^0-9]\+//" \
    | sed "s/ (.*$//g" | sed "s/^[0-9]\+-//" | tr '\n' '.    ' \
    | sed "s/\.$/\n/")"\n"
else
  echo -e $(tput setaf 9)"Not OK"$(tput sgr0)
fi

[ -d ${CLONE_DIR} ] && sudo \rm -rf ${CLONE_DIR}
command mkdir -p ${CLONE_DIR}

unbuffer git clone https://github.com/vim/vim.git ${CLONE_DIR}/vim \
  | unbuffer -p grep -E -o "[0-9]+%" \
  | xargs -I {} echo -n -e ${CLEAR}"Cloning VIM repository ------------------------------------------- {}" \
  && echo -e ${CLEAR}"Cloning VIM repository ------------------------------------------- "$(tput setaf 2)"OK   "$(tput sgr0)

[ $? -ne 0 ] && echo -e ${CLEAR}"Cloning VIM repository ------------------------------------------- "$(tput setaf 9)"Not OK"$(tput sgr0) \
  && sudo \rm -rf ${CLONE_DIR} && return 1

command cd ${CLONE_DIR}/vim/src

chrono "Configuring VIM -------------------------------------------------- " &
CHRONO_PID=$!
./configure &> /dev/null
STATUS=$?

pkill $(ps -q ${CHRONO_PID} -o comm=)
wait ${CHRONO_PID} &> /dev/null && echo -n -e ${CLEAR}

if [ ${STATUS} -eq 0 ]; then
  echo -e "Configuring VIM -------------------------------------------------- "$(tput setaf 2)"OK   "$(tput sgr0)
else
  echo -e "Configuring VIM -------------------------------------------------- "$(tput setaf 9)"Not OK"$(tput sgr0) \
    && command cd ${BACKUP} && sudo \rm -rf ${CLONE_DIR} && return 1
fi

chrono "Making VIM ------------------------------------------------------- " &
CHRONO_PID=$!
make &> /dev/null
STATUS=$?

pkill $(ps -q ${CHRONO_PID} -o comm=)
wait ${CHRONO_PID} &> /dev/null && echo -n -e ${CLEAR}

if [ ${STATUS} -eq 0 ]; then
  echo -e "Making VIM ------------------------------------------------------- "$(tput setaf 2)"OK   "$(tput sgr0)
else
  echo -e "Making VIM ------------------------------------------------------- "$(tput setaf 9)"Not OK"$(tput sgr0) \
    && command cd ${BACKUP} && sudo \rm -rf ${CLONE_DIR} && return 1
fi

chrono "Installing VIM --------------------------------------------------- " &
CHRONO_PID=$!
sudo make install &> /dev/null
STATUS=$?

pkill $(ps -q ${CHRONO_PID} -o comm=)
wait ${CHRONO_PID} &> /dev/null && echo -n -e ${CLEAR}

if [ ${STATUS} -eq 0 ]; then
  echo -e "Installing VIM --------------------------------------------------- "$(tput setaf 2)"OK   "$(tput sgr0)
else
  echo -e "Installing VIM --------------------------------------------------- "$(tput setaf 9)"Not OK"$(tput sgr0) \
    && command cd ${BACKUP} && sudo \rm -rf ${CLONE_DIR} && return 1
fi

echo -e "\nvim "$(vim --version \
  | head -n 2 | sed "s/^[^0-9]\+//" | sed "s/ (.*$//g" | sed "s/^[0-9]\+-//" \
  | tr '\n' '.    ' | sed "s/\.$/\n/")"\n"

echo -n "Checking TMUX version -------------------------------------------- "
if [ $(which tmux | wc -l) -eq 1 ]; then
  echo -e $(tput setaf 2)"OK   "$(tput sgr0)
  echo -e "\n"$(tmux -V)"\n"
else
  echo -e $(tput setaf 9)"Not OK"$(tput sgr0)
fi

unbuffer git clone https://github.com/tmux/tmux.git ${CLONE_DIR}/tmux \
  | unbuffer -p grep -E -o "[0-9]+%" \
  | xargs -I {} echo -n -e ${CLEAR}"Cloning TMUX repository ------------------------------------------ {}" \
  && echo -e ${CLEAR}"Cloning TMUX repository ------------------------------------------ "$(tput setaf 2)"OK   "$(tput sgr0)

[ $? -ne 0 ] && echo -e ${CLEAR}"Cloning TMUX repository ------------------------------------------ "$(tput setaf 9)"Not OK"$(tput sgr0) \
  && command cd ${BACKUP} && sudo \rm -rf ${CLONE_DIR} && return 1

chrono "Configuring TMUX ------------------------------------------------- " &
CHRONO_PID=$!
command cd ${CLONE_DIR}/tmux && sh autogen.sh &> /dev/null \
  && ./configure &> /dev/null
STATUS=$?

pkill $(ps -q ${CHRONO_PID} -o comm=)
wait ${CHRONO_PID} &> /dev/null && echo -n -e ${CLEAR}

if [ ${STATUS} -eq 0 ]; then
  echo -e "Configuring TMUX ------------------------------------------------- "$(tput setaf 2)"OK   "$(tput sgr0)
else
  echo -e "Configuring TMUX ------------------------------------------------- "$(tput setaf 9)"Not OK"$(tput sgr0) \
    && command cd ${BACKUP} && sudo \rm -rf ${CLONE_DIR} && return 1
fi

chrono "Making TMUX ------------------------------------------------------ " &
CHRONO_PID=$!
make &> /dev/null
STATUS=$?

pkill $(ps -q ${CHRONO_PID} -o comm=)
wait ${CHRONO_PID} &> /dev/null && echo -n -e ${CLEAR}

if [ ${STATUS} -eq 0 ]; then
  echo -e "Making TMUX ------------------------------------------------------ "$(tput setaf 2)"OK   "$(tput sgr0)
else
  echo -e "Making TMUX ------------------------------------------------------ "$(tput setaf 9)"Not OK"$(tput sgr0) \
    && command cd ${BACKUP} && sudo \rm -rf ${CLONE_DIR} && return 1
fi

chrono "Installing TMUX -------------------------------------------------- " &
CHRONO_PID=$!
sudo make install &> /dev/null
STATUS=$?

pkill $(ps -q ${CHRONO_PID} -o comm=)
wait ${CHRONO_PID} &> /dev/null && echo -n -e ${CLEAR}

if [ ${STATUS} -eq 0 ]; then
  echo -e "Installing TMUX -------------------------------------------------- "$(tput setaf 2)"OK   "$(tput sgr0)
else
  echo -e "Installing TMUX -------------------------------------------------- "$(tput setaf 9)"Not OK"$(tput sgr0) \
    && command cd ${BACKUP} && sudo \rm -rf ${CLONE_DIR} && return 1
fi

echo -e "\n"$(tmux -V)"\n"

TPM_DEST="${HOME}/.tmux/plugins/tpm"
[ -d ${TPM_DEST} ] && sudo \rm -rf ${TPM_DEST}
unbuffer git clone https://github.com/tmux-plugins/tpm ${TPM_DEST} \
  | unbuffer -p grep -E -o "[0-9]+%" \
  | xargs -I {} echo -n -e ${CLEAR}"Cloning TMUX Plugin Manager repository --------------------------- {}" \
  && echo -e ${CLEAR}"Cloning TMUX Plugin Manager repository --------------------------- "$(tput setaf 2)"OK   "$(tput sgr0)

[ $? -ne 0 ] && echo -e ${CLEAR}"Cloning TMUX Plugin Manager repository --------------------------- "$(tput setaf 9)"Not OK"$(tput sgr0) \
  && command cd ${BACKUP} && sudo \rm -rf ${CLONE_DIR} && return 1

if [ ${GNOME} -eq 1 ]; then
  EXECUTOR_DEST="${HOME}/.local/share/gnome-shell"
  EXECUTOR_DEST+="/extensions/executor@raujonas.github.io/"
  [ -d ${EXECUTOR_DEST} ] && sudo \rm -rf ${EXECUTOR_DEST}
  unbuffer git clone https://github.com/raujonas/executor.git ${EXECUTOR_DEST} \
    | unbuffer -p grep -E -o "[0-9]+%" \
    | xargs -I {} echo -n -e ${CLEAR}"Cloning EXECUTOR repository -------------------------------------- {}" \
    && echo -e ${CLEAR}"Cloning EXECUTOR repository -------------------------------------- "$(tput setaf 2)"OK   "$(tput sgr0)

  [ $? -ne 0 ] && echo -e ${CLEAR}"Cloning EXECUTOR repository -------------------------------------- "$(tput setaf 9)"Not OK"$(tput sgr0) \
    && command cd ${BACKUP} && sudo \rm -rf ${CLONE_DIR} && return 1
fi

command cd ${SCRIPT_DIR} && sudo \rm -rf ${CLONE_DIR}

chrono "Copying .vimrc --------------------------------------------------- " &
CHRONO_PID=$!
command cp vim/.vimrc ${HOME} &> /dev/null
STATUS=$?

pkill $(ps -q ${CHRONO_PID} -o comm=)
wait ${CHRONO_PID} &> /dev/null && echo -n -e ${CLEAR}

if [ ${STATUS} -eq 0 ]; then
  echo -e "Copying .vimrc --------------------------------------------------- "$(tput setaf 2)"OK   "$(tput sgr0)
else
  echo -e "Copying .vimrc --------------------------------------------------- "$(tput setaf 9)"Not OK"$(tput sgr0) \
    && command cd ${BACKUP} && return 1
fi

chrono "Copying .tmux.conf ----------------------------------------------- " &
CHRONO_PID=$!
command cp tmux/.tmux.conf ${HOME} &> /dev/null
STATUS=$?

pkill $(ps -q ${CHRONO_PID} -o comm=)
wait ${CHRONO_PID} &> /dev/null && echo -n -e ${CLEAR}

if [ ${STATUS} -eq 0 ]; then
  echo -e "Copying .tmux.conf ----------------------------------------------- "$(tput setaf 2)"OK   "$(tput sgr0)
else
  echo -e "Copying .tmux.conf ----------------------------------------------- "$(tput setaf 9)"Not OK"$(tput sgr0) \
    && command cd ${BACKUP} && return 1
fi

chrono "Installing TMUX Plugins ------------------------------------------ " &
CHRONO_PID=$!
${HOME}/.tmux/plugins/tpm/bin/install_plugins &> /dev/null
STATUS=$?

pkill $(ps -q ${CHRONO_PID} -o comm=)
wait ${CHRONO_PID} &> /dev/null && echo -n -e ${CLEAR}

if [ ${STATUS} -eq 0 ]; then
  echo -e "Installing TMUX Plugins ------------------------------------------ "$(tput setaf 2)"OK   "$(tput sgr0)
else
  echo -e "Installing TMUX Plugins ------------------------------------------ "$(tput setaf 9)"Not OK"$(tput sgr0) \
    && command cd ${BACKUP} && return 1
fi

chrono "Copying .bashrc -------------------------------------------------- " &
CHRONO_PID=$!
command cp /etc/skel/.bashrc ${HOME} &> /dev/null \
  && echo -e "\n$(cat bash/.bashrc/basic_settings)" >> ${HOME}/.bashrc

if [ $? -ne 0 ]; then
  pkill $(ps -q ${CHRONO_PID} -o comm=)
  wait ${CHRONO_PID} &> /dev/null && echo -n -e ${CLEAR}
  echo -e "Copying .bashrc -------------------------------------------------- "$(tput setaf 9)"Not OK"$(tput sgr0) \
    && command cd ${BACKUP} && return 1
else
  if [ ${GNOME} -eq 1 ]; then
    echo -e "\n$(cat bash/.bashrc/redshift_settings)" >> ${HOME}/.bashrc
    STATUS=$?
    pkill $(ps -q ${CHRONO_PID} -o comm=)
    wait ${CHRONO_PID} &> /dev/null && echo -n -e ${CLEAR}
    if [ ${STATUS} -eq 0 ]; then
      echo -e "Copying .bashrc -------------------------------------------------- "$(tput setaf 2)"OK   "$(tput sgr0)
    else
      echo -e "Copying .bashrc -------------------------------------------------- "$(tput setaf 9)"Not OK"$(tput sgr0) \
        && command cd ${BACKUP} && return 1
    fi
  else
    pkill $(ps -q ${CHRONO_PID} -o comm=)
    wait ${CHRONO_PID} &> /dev/null && echo -n -e ${CLEAR}
    echo -e "Copying .bashrc -------------------------------------------------- "$(tput setaf 2)"OK   "$(tput sgr0)
  fi
fi

chrono "Copying .bash_profile -------------------------------------------- " &
CHRONO_PID=$!
command cp bash/.bash_profile ${HOME} &> /dev/null
STATUS=$?

pkill $(ps -q ${CHRONO_PID} -o comm=)
wait ${CHRONO_PID} &> /dev/null && echo -n -e ${CLEAR}

if [ ${STATUS} -eq 0 ]; then
  echo -e "Copying .bash_profile -------------------------------------------- "$(tput setaf 2)"OK   "$(tput sgr0)
else
  echo -e "Copying .bash_profile -------------------------------------------- "$(tput setaf 9)"Not OK"$(tput sgr0) \
    && command cd ${BACKUP} && return 1
fi

chrono "Copying .bash_aliases -------------------------------------------- " &
CHRONO_PID=$!
command cp bash/.bash_aliases/usual ${HOME}/.bash_aliases &> /dev/null
STATUS=$?

pkill $(ps -q ${CHRONO_PID} -o comm=)
wait ${CHRONO_PID} &> /dev/null && echo -n -e ${CLEAR}

if [ ${STATUS} -eq 0 ]; then
  echo -e "Copying .bash_aliases -------------------------------------------- "$(tput setaf 2)"OK   "$(tput sgr0)
else
  echo -e "Copying .bash_aliases -------------------------------------------- "$(tput setaf 9)"Not OK"$(tput sgr0) \
    && command cd ${BACKUP} && return 1
fi

GIT_TEMPLATE_DIR="/usr/share/git-core/templates"

chrono "Copying .gitignore ----------------------------------------------- " &
CHRONO_PID=$!
sudo \cp git/.gitignore ${GIT_TEMPLATE_DIR} &> /dev/null
STATUS=$?

pkill $(ps -q ${CHRONO_PID} -o comm=)
wait ${CHRONO_PID} &> /dev/null && echo -n -e ${CLEAR}

if [ ${STATUS} -eq 0 ]; then
  echo -e "Copying .gitignore ----------------------------------------------- "$(tput setaf 2)"OK   "$(tput sgr0)
else
  echo -e "Copying .gitignore ----------------------------------------------- "$(tput setaf 9)"Not OK"$(tput sgr0) \
    && command cd ${BACKUP} && return 1
fi

chrono "Copying GIT hooks ------------------------------------------------ " &
CHRONO_PID=$!
sudo \cp -r git/.hooks ${GIT_TEMPLATE_DIR} &> /dev/null
STATUS=$?

pkill $(ps -q ${CHRONO_PID} -o comm=)
wait ${CHRONO_PID} &> /dev/null && echo -n -e ${CLEAR}

if [ ${STATUS} -eq 0 ]; then
  echo -e "Copying GIT hooks ------------------------------------------------ "$(tput setaf 2)"OK   "$(tput sgr0)
else
  echo -e "Copying GIT hooks ------------------------------------------------ "$(tput setaf 9)"Not OK"$(tput sgr0) \
    && command cd ${BACKUP} && return 1
fi

if [ ${GNOME} -eq 1 ]; then
  chrono "Copying executor scripts ----------------------------------------- " &
  CHRONO_PID=$!
  [ -d ${HOME}/.executor ] && sudo \rm -rf ${HOME}/.executor
  command cp -r executor ${HOME}/.executor &> /dev/null
  STATUS=$?

  pkill $(ps -q ${CHRONO_PID} -o comm=)
  wait ${CHRONO_PID} &> /dev/null && echo -n -e ${CLEAR}

  if [ ${STATUS} -eq 0 ]; then
    echo -e "Copying executor scripts ----------------------------------------- "$(tput setaf 2)"OK   "$(tput sgr0)
  else
    echo -e "Copying executor scripts ----------------------------------------- "$(tput setaf 9)"Not OK"$(tput sgr0) \
      && command cd ${BACKUP} && return 1
  fi

  [ $? -ne 0 ] && echo -e $(tput setaf 9)"Not OK"$(tput sgr0) \
    && command cd ${BACKUP} && return 1

  chrono "Enabling EXECUTOR ------------------------------------------------ " &
  CHRONO_PID=$!
  gnome-extensions enable executor@raujonas.github.io &> /dev/null
  STATUS=$?

  pkill $(ps -q ${CHRONO_PID} -o comm=)
  wait ${CHRONO_PID} &> /dev/null && echo -n -e ${CLEAR}

  if [ ${STATUS} -eq 0 ]; then
    echo -e "Enabling EXECUTOR ------------------------------------------------ "$(tput setaf 2)"OK   "$(tput sgr0)
  else
    echo -e "Enabling EXECUTOR ------------------------------------------------ "$(tput setaf 9)"Not OK"$(tput sgr0) \
      && command cd ${BACKUP} && return 1
  fi

  chrono "Restarting GNOME ------------------------------------------------- " &
  CHRONO_PID=$!
  killall -3 gnome-shell &> /dev/null
  STATUS=$?

  pkill $(ps -q ${CHRONO_PID} -o comm=)
  wait ${CHRONO_PID} &> /dev/null && echo -n -e ${CLEAR}

  if [ ${STATUS} -eq 0 ]; then
    echo -e "Restarting GNOME ------------------------------------------------- "$(tput setaf 2)"OK   "$(tput sgr0)
  else
    echo -e "Restarting GNOME ------------------------------------------------- "$(tput setaf 9)"Not OK"$(tput sgr0) \
      && command cd ${BACKUP} && return 1
  fi

  echo -n -e "\nPress Enter when GNOME service is functional again " \
    && read && echo
fi

chrono "Sourcing .bashrc ------------------------------------------------- " &
CHRONO_PID=$!
source ${HOME}/.bashrc &> /dev/null
STATUS=$?

pkill $(ps -q ${CHRONO_PID} -o comm=)
wait ${CHRONO_PID} &> /dev/null && echo -n -e ${CLEAR}

if [ ${STATUS} -eq 0 ]; then
  echo -e "Sourcing .bashrc ------------------------------------------------- "$(tput setaf 2)"OK   "$(tput sgr0)
else
  echo -e "Sourcing .bashrc ------------------------------------------------- "$(tput setaf 9)"Not OK"$(tput sgr0) \
    && command cd ${BACKUP} && return 1
fi

command cd ${BACKUP}
