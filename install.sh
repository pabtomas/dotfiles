#!/bin/bash

(return 0 2>/dev/null)
[ $? -ne 0 ] && echo "This script has to be sourced." && exit 1
sudo -k && sudo echo > /dev/null 2>&1

echo -n "Checking apt installation ---------------------------------------- "
if [ $(which apt | wc -l) -gt 0 ]; then
  echo -e $(tput setaf 2)"OK"$(tput sgr0)
else
  echo -e $(tput setaf 9)"Not OK"$(tput sgr0) && return 1
fi

GNOME=1
echo -n "Checking GNOME installation -------------------------------------- "
if [ $(echo "${XDG_CURRENT_DESKTOP}" | grep -E "GNOME" | wc -l) -gt 0 ] \
  && [ $(which gnome-shell | wc -l) -gt 0 ]; then
    echo -e $(tput setaf 2)"OK"$(tput sgr0)
else
  echo -e $(tput setaf 9)"Not OK"$(tput sgr0) && GNOME=0
fi

if [ ${GNOME} -eq 1 ]; then
  echo -n "Checking GNOME version ------------------------------------------- "
  if [ $(echo -e $(gnome-shell --version | sed "s/^[^0-9]\+//")"\n3.30.1" \
    | sort -V | head -n1) == "3.30.1" ]; then
      echo -e $(tput setaf 2)"OK"$(tput sgr0)
  else
    echo -e $(tput setaf 9)"Not OK"$(tput sgr0) \
      && echo -e "\n$(gnome-shell --version)\n" && GNOME=0
  fi
fi

CLONE_DIR=/tmp/repositories_clone
BACKUP=$(pwd)

echo -n "Updating system -------------------------------------------------- "
sudo apt update -y > /dev/null 2>&1 && echo -e $(tput setaf 2)"OK"$(tput sgr0)

[ $? -ne 0 ] && echo -e $(tput setaf 9)"Not OK"$(tput sgr0) && return 1

echo -n "Upgrading system ------------------------------------------------- "
sudo apt upgrade -y > /dev/null 2>&1 && echo -e $(tput setaf 2)"OK"$(tput sgr0)

[ $? -ne 0 ] && echo -e $(tput setaf 9)"Not OK"$(tput sgr0) && return 1

echo -n "Removing unused packages ----------------------------------------- "
sudo apt autoremove -y > /dev/null 2>&1 \
  && echo -e $(tput setaf 2)"OK"$(tput sgr0)

[ $? -ne 0 ] && echo -e $(tput setaf 9)"Not OK"$(tput sgr0) && return 1

echo -n "Checking GIT installation ---------------------------------------- "
if [ $(which git | wc -l) -eq 0 ]; then
  echo -e $(tput setaf 9)"Not OK"$(tput sgr0)
  echo -n "Installing GIT package ------------------------------------------- "
  sudo apt install -y git > /dev/null 2>&1 \
    && echo -e $(tput setaf 2)"OK"$(tput sgr0)
else
  echo -e $(tput setaf 2)"OK"$(tput sgr0)
fi

[ $? -ne 0 ] && echo -e $(tput setaf 9)"Not OK"$(tput sgr0) && return 1

echo -n "Checking libncurses-dev installation ----------------------------- "
if [ $(dpkg -l | command grep -E "libncurses-dev" | wc -l) -eq 0 ]; then
  echo -e $(tput setaf 9)"Not OK"$(tput sgr0)
  echo -n "Installing libncurses-dev package -------------------------------- "
  sudo apt install -y libncurses-dev > /dev/null 2>&1 \
    && echo -e $(tput setaf 2)"OK"$(tput sgr0)
else
  echo -e $(tput setaf 2)"OK"$(tput sgr0)
fi

[ $? -ne 0 ] && echo -e $(tput setaf 9)"Not OK"$(tput sgr0) && return 1

echo -n "Checking libevent-dev installation ------------------------------- "
if [ $(dpkg -l | command grep -E "libevent-dev" | wc -l) -eq 0 ]; then
  echo -e $(tput setaf 9)"Not OK"$(tput sgr0)
  echo -n "Installing libevent-dev package ---------------------------------- "
  sudo apt install -y libevent-dev > /dev/null 2>&1 \
    && echo -e $(tput setaf 2)"OK"$(tput sgr0)
else
  echo -e $(tput setaf 2)"OK"$(tput sgr0)
fi

[ $? -ne 0 ] && echo -e $(tput setaf 9)"Not OK"$(tput sgr0) && return 1

echo -n "Checking gcc installation ---------------------------------------- "
if [ $(which gcc | wc -l) -eq 0 ]; then
  echo -e $(tput setaf 9)"Not OK"$(tput sgr0)
  echo -n "Installing build-essential package ------------------------------- "
  sudo apt install -y build-essential > /dev/null 2>&1 \
    && echo -e $(tput setaf 2)"OK"$(tput sgr0)
else
  echo -e $(tput setaf 2)"OK"$(tput sgr0)
fi

[ $? -ne 0 ] && echo -e $(tput setaf 9)"Not OK"$(tput sgr0) && return 1

echo -n "Checking yacc installation --------------------------------------- "
if [ $(which yacc | wc -l) -eq 0 ]; then
  echo -e $(tput setaf 9)"Not OK"$(tput sgr0)
  echo -n "Installing bison package ----------------------------------------- "
  sudo apt install -y bison > /dev/null 2>&1 \
    && echo -e $(tput setaf 2)"OK"$(tput sgr0)
else
  echo -e $(tput setaf 2)"OK"$(tput sgr0)
fi

[ $? -ne 0 ] && echo -e $(tput setaf 9)"Not OK"$(tput sgr0) && return 1

echo -n "Checking make installation --------------------------------------- "
if [ $(which make | wc -l) -eq 0 ]; then
  echo -e $(tput setaf 9)"Not OK"$(tput sgr0)
  echo -n "Installing make package ------------------------------------------ "
  sudo apt install -y make > /dev/null 2>&1 \
    && echo -e $(tput setaf 2)"OK"$(tput sgr0)
else
  echo -e $(tput setaf 2)"OK"$(tput sgr0)
fi

[ $? -ne 0 ] && echo -e $(tput setaf 9)"Not OK"$(tput sgr0) && return 1

echo -n "Checking automake installation ----------------------------------- "
if [ $(dpkg -l | command grep -E "automake" | wc -l) -eq 0 ]; then
  echo -e $(tput setaf 9)"Not OK"$(tput sgr0)
  echo -n "Installing automake package -------------------------------------- "
  sudo apt install -y automake > /dev/null 2>&1 \
    && echo -e $(tput setaf 2)"OK"$(tput sgr0)
else
  echo -e $(tput setaf 2)"OK"$(tput sgr0)
fi

[ $? -ne 0 ] && echo -e $(tput setaf 9)"Not OK"$(tput sgr0) && return 1

echo -n "Checking autoconf installation ----------------------------------- "
if [ $(dpkg -l | command grep -E "autoconf" | wc -l) -eq 0 ]; then
  echo -e $(tput setaf 9)"Not OK"$(tput sgr0)
  echo -n "Installing autoconf package -------------------------------------- "
  sudo apt install -y autoconf > /dev/null 2>&1 \
    && echo -e $(tput setaf 2)"OK"$(tput sgr0)
else
  echo -e $(tput setaf 2)"OK"$(tput sgr0)
fi

[ $? -ne 0 ] && echo -e $(tput setaf 9)"Not OK"$(tput sgr0) && return 1

echo -n "Checking pkg-config installation --------------------------------- "
if [ $(dpkg -l | command grep -E "pkg-config" | wc -l) -eq 0 ]; then
  echo -e $(tput setaf 9)"Not OK"$(tput sgr0)
  echo -n "Installing pkg-config package ------------------------------------ "
  sudo apt install -y pkg-config > /dev/null 2>&1 \
    && echo -e $(tput setaf 2)"OK"$(tput sgr0)
else
  echo -e $(tput setaf 2)"OK"$(tput sgr0)
fi

[ $? -ne 0 ] && echo -e $(tput setaf 9)"Not OK"$(tput sgr0) && return 1

if [ ${GNOME} -eq 1 ]; then
  echo -n "Checking redshift installation ----------------------------------- "
  if [ $(which redshift | wc -l) -eq 0 ]; then
    echo -e $(tput setaf 9)"Not OK"$(tput sgr0)
    echo -n "Installing redshift package -------------------------------------- "
    sudo apt install -y redshift > /dev/null 2>&1 \
      && echo -e $(tput setaf 2)"OK"$(tput sgr0)
  else
    echo -e $(tput setaf 2)"OK"$(tput sgr0)
  fi

  [ $? -ne 0 ] && echo -e $(tput setaf 9)"Not OK"$(tput sgr0) && return 1
fi

echo -n "Checking VIM version --------------------------------------------- "
if [ $(which vim | wc -l) -eq 1 ]; then
  echo -e $(tput setaf 2)"OK"$(tput sgr0)
  echo -e "\nvim "$(vim --version | head -n 2 | sed "s/^[^0-9]\+//" \
    | sed "s/ (.*$//g" | sed "s/^[0-9]\+-//" | tr '\n' '.    ' \
    | sed "s/\.$/\n/")"\n"
else
  echo -e $(tput setaf 9)"Not OK"$(tput sgr0)
fi

[ -d ${CLONE_DIR} ] && sudo \rm -rf ${CLONE_DIR}
command mkdir -p ${CLONE_DIR} && command cd ${CLONE_DIR}

echo -n "Cloning VIM repository ------------------------------------------- "
git clone https://github.com/vim/vim.git > /dev/null 2>&1 \
  && echo -e $(tput setaf 2)"OK"$(tput sgr0)

[ $? -ne 0 ] && echo -e $(tput setaf 9)"Not OK"$(tput sgr0) \
  && command cd ${BACKUP} && sudo \rm -rf ${CLONE_DIR} && return 1

command cd ${CLONE_DIR}/vim/src
echo -n "Configuring VIM -------------------------------------------------- "
./configure > /dev/null 2>&1 && echo -e $(tput setaf 2)"OK"$(tput sgr0)

[ $? -ne 0 ] && echo -e $(tput setaf 9)"Not OK"$(tput sgr0) \
  && command cd ${BACKUP} && sudo \rm -rf ${CLONE_DIR} && return 1

echo -n "Making VIM ------------------------------------------------------- "
make > /dev/null 2>&1 && echo -e $(tput setaf 2)"OK"$(tput sgr0)

[ $? -ne 0 ] && echo -e $(tput setaf 9)"Not OK"$(tput sgr0) \
  && command cd ${BACKUP} && sudo \rm -rf ${CLONE_DIR} && return 1

echo -n "Installing VIM --------------------------------------------------- "
sudo make install > /dev/null 2>&1 && echo -e $(tput setaf 2)"OK"$(tput sgr0)

[ $? -ne 0 ] && echo -e $(tput setaf 9)"Not OK"$(tput sgr0) \
  && command cd ${BACKUP} && sudo \rm -rf ${CLONE_DIR} && return 1

echo -e "\nvim "$(vim --version \
  | head -n 2 | sed "s/^[^0-9]\+//" | sed "s/ (.*$//g" | sed "s/^[0-9]\+-//" \
  | tr '\n' '.    ' | sed "s/\.$/\n/")"\n"

echo -n "Checking TMUX version -------------------------------------------- "
if [ $(which tmux | wc -l) -eq 1 ]; then
  echo -e $(tput setaf 2)"OK"$(tput sgr0)
  echo -e "\n"$(tmux -V)"\n"
else
  echo -e $(tput setaf 9)"Not OK"$(tput sgr0)
fi

command cd ${CLONE_DIR}
echo -n "Cloning TMUX repository ------------------------------------------ "
git clone https://github.com/tmux/tmux.git > /dev/null 2>&1 \
  && echo -e $(tput setaf 2)"OK"$(tput sgr0)

[ $? -ne 0 ] && echo -e $(tput setaf 9)"Not OK"$(tput sgr0) \
  && command cd ${BACKUP} && sudo \rm -rf ${CLONE_DIR} && return 1

echo -n "Configuring TMUX ------------------------------------------------- "
command cd ${CLONE_DIR}/tmux && sh autogen.sh > /dev/null 2>&1
./configure > /dev/null 2>&1 && echo -e $(tput setaf 2)"OK"$(tput sgr0)

[ $? -ne 0 ] && echo -e $(tput setaf 9)"Not OK"$(tput sgr0) \
  && command cd ${BACKUP} && sudo \rm -rf ${CLONE_DIR} && return 1

echo -n "Making TMUX ------------------------------------------------------ "
make > /dev/null 2>&1 && echo -e $(tput setaf 2)"OK"$(tput sgr0)

[ $? -ne 0 ] && echo -e $(tput setaf 9)"Not OK"$(tput sgr0) \
  && command cd ${BACKUP} && sudo \rm -rf ${CLONE_DIR} && return 1

echo -n "Installing TMUX -------------------------------------------------- "
sudo make install > /dev/null 2>&1 && echo -e $(tput setaf 2)"OK"$(tput sgr0)

[ $? -ne 0 ] && echo -e $(tput setaf 9)"Not OK"$(tput sgr0) \
  && command cd ${BACKUP} && sudo \rm -rf ${CLONE_DIR} && return 1

echo -e "\n"$(tmux -V)"\n"

if [ ${GNOME} -eq 1 ]; then
  echo -n "Cloning EXECUTOR repository -------------------------------------- "
  EXECUTOR_DEST="${HOME}/.local/share/gnome-shell"
  EXECUTOR_DEST+="/extensions/executor@raujonas.github.io/"
  [ -d ${EXECUTOR_DEST} ] && sudo \rm -rf ${EXECUTOR_DEST}
  sudo git clone https://github.com/raujonas/executor.git ${EXECUTOR_DEST} > \
    /dev/null 2>&1 && echo -e $(tput setaf 2)"OK"$(tput sgr0)

  [ $? -ne 0 ] && echo -e $(tput setaf 9)"Not OK"$(tput sgr0) \
    && command cd ${BACKUP} && sudo \rm -rf ${CLONE_DIR} && return 1
fi

command cd ${BACKUP} && sudo \rm -rf ${CLONE_DIR}

echo -n "Copying .vimrc --------------------------------------------------- "
command cp vim/.vimrc ${HOME} > /dev/null 2>&1 \
  && echo -e $(tput setaf 2)"OK"$(tput sgr0)

[ $? -ne 0 ] && echo -e $(tput setaf 9)"Not OK"$(tput sgr0) && return 1

echo -n "Copying .tmux.conf ----------------------------------------------- "
command cp tmux/.tmux.conf ${HOME} > /dev/null 2>&1 \
  && echo -e $(tput setaf 2)"OK"$(tput sgr0)

[ $? -ne 0 ] && echo -e $(tput setaf 9)"Not OK"$(tput sgr0) && return 1

echo -n "Copying .bashrc -------------------------------------------------- "
command cp /etc/skel/.bashrc ${HOME} > /dev/null 2>&1 \
  && echo -e "\n$(cat bash/.bashrc/basic_settings)" >> ${HOME}/.bashrc \
  && [ ${GNOME} -eq 1 ] && echo -e "\n$(cat bash/.bashrc/redshift_settings)" \
    >> ${HOME}/.bashrc

if [ $? -ne 0 ]; then
  echo -e $(tput setaf 9)"Not OK"$(tput sgr0) && return 1
else
  echo -e $(tput setaf 2)"OK"$(tput sgr0)
fi

echo -n "Copying .bash_profile -------------------------------------------- "
command cp bash/.bash_profile ${HOME} > /dev/null 2>&1 \
  && echo -e $(tput setaf 2)"OK"$(tput sgr0)

[ $? -ne 0 ] && echo -e $(tput setaf 9)"Not OK"$(tput sgr0) && return 1

echo -n "Copying .bash_aliases -------------------------------------------- "
command cp bash/.bash_aliases ${HOME} > /dev/null 2>&1 \
  && echo -e $(tput setaf 2)"OK"$(tput sgr0)

[ $? -ne 0 ] && echo -e $(tput setaf 9)"Not OK"$(tput sgr0) && return 1

if [ ${GNOME} -eq 1 ]; then
  echo -n "Copying executor scripts ----------------------------------------- "
  [ -d ${HOME}/.executor ] && sudo \rm -rf ${HOME}/.executor
  command cp -r executor ${HOME}/.executor > /dev/null 2>&1 \
    && echo -e $(tput setaf 2)"OK"$(tput sgr0)

  [ $? -ne 0 ] && echo -e $(tput setaf 9)"Not OK"$(tput sgr0) && return 1

  echo -n "Enabling EXECUTOR ------------------------------------------------ "
  gnome-extensions enable executor@raujonas.github.io \
    && echo -e $(tput setaf 2)"OK"$(tput sgr0)

  [ $? -ne 0 ] && echo -e $(tput setaf 9)"Not OK"$(tput sgr0) && return 1

  echo -n "Restarting GNOME ------------------------------------------------- "
  killall -3 gnome-shell > /dev/null && echo -e $(tput setaf 2)"OK"$(tput sgr0)

  [ $? -ne 0 ] && echo -e $(tput setaf 9)"Not OK"$(tput sgr0) && return 1
fi

echo -n "Sourcing .bashrc ------------------------------------------------- "
source ${HOME}/.bashrc > /dev/null && echo -e $(tput setaf 2)"OK"$(tput sgr0)

[ $? -ne 0 ] && echo -e $(tput setaf 9)"Not OK"$(tput sgr0) && return 1
