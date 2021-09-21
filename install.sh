#!/bin/bash

(return 0 2>/dev/null)
[ $? -ne 0 ] && echo "This script has to be sourced." && exit 1
sudo -k && sudo echo &> /dev/null

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

NC="$(tput sgr0)"

sudo unbuffer apt update -y | unbuffer -p grep -E "[0-9]+%" \
  | sed --unbuffered "s/[^0-9]*\([0-9]\+%\).*/"${NC}"\1/" \
  | xargs -I {} echo -n "Updating system -------------------------------------------------- {}   " $'\r' \
  && echo -e "Updating system -------------------------------------------------- "$(tput setaf 2)"OK   "$(tput sgr0)

[ $? -ne 0 ] && echo -e "Updating system -------------------------------------------------- "$(tput setaf 9)"Not OK"$(tput sgr0) && return 1

sudo unbuffer apt upgrade -y | unbuffer -p grep -E "[0-9]+%" \
  | sed --unbuffered "s/[^0-9]*\([0-9]\+%\).*/"${NC}"\1/" \
  | xargs -I {} echo -n "Upgrading system ------------------------------------------------- {}   " $'\r' \
  && echo -e "Upgrading system ------------------------------------------------- "$(tput setaf 2)"OK   "$(tput sgr0)

[ $? -ne 0 ] && echo -e "Upgrading system ------------------------------------------------- "$(tput setaf 9)"Not OK"$(tput sgr0) && return 1

sudo unbuffer apt autoremove -y | unbuffer -p grep -E "[0-9]+%" \
  | sed --unbuffered "s/[^0-9]*\([0-9]\+%\).*/"${NC}"\1/" \
  | xargs -I {} echo -n "Removing unused packages ----------------------------------------- {}   " $'\r' \
  && echo -e "Removing unused packages ----------------------------------------- "$(tput setaf 2)"OK   "$(tput sgr0)

[ $? -ne 0 ] && echo -e "Removing unused packages ----------------------------------------- "$(tput setaf 9)"Not OK"$(tput sgr0) && return 1

echo -n "Checking GIT installation ---------------------------------------- "
if [ $(which git | wc -l) -eq 0 ]; then
  echo -e $(tput setaf 9)"Not OK"$(tput sgr0)
  sudo unbuffer apt install -y | unbuffer -p grep -E "[0-9]+%" \
    | sed --unbuffered "s/[^0-9]*\([0-9]\+%\).*/"${NC}"\1/" \
    | xargs -I {} echo -n "Installing GIT package ------------------------------------------- {}   " $'\r' \
    && echo -e "Installing GIT package ------------------------------------------- "$(tput setaf 2)"OK   "$(tput sgr0)
else
  echo -e $(tput setaf 2)"OK   "$(tput sgr0)
fi

[ $? -ne 0 ] && echo -e "Installing GIT package ------------------------------------------- "$(tput setaf 9)"Not OK"$(tput sgr0) && return 1

echo -n "Checking libncurses-dev installation ----------------------------- "
if [ $(dpkg -l | command grep -E "libncurses-dev" | wc -l) -eq 0 ]; then
  echo -e $(tput setaf 9)"Not OK"$(tput sgr0)
  sudo unbuffer apt install -y libncurses-dev | unbuffer -p grep -E "[0-9]+%" \
    | sed --unbuffered "s/[^0-9]*\([0-9]\+%\).*/"${NC}"\1/" \
    | xargs -I {} echo -n "Installing libncurses-dev package -------------------------------- {}   " $'\r' \
    && echo -e "Installing libncurses-dev package -------------------------------- "$(tput setaf 2)"OK   "$(tput sgr0)
else
  echo -e $(tput setaf 2)"OK   "$(tput sgr0)
fi

[ $? -ne 0 ] && echo -e "Installing libncurses-dev package -------------------------------- "$(tput setaf 9)"Not OK"$(tput sgr0) && return 1

echo -n "Checking libevent-dev installation ------------------------------- "
if [ $(dpkg -l | command grep -E "libevent-dev" | wc -l) -eq 0 ]; then
  echo -e $(tput setaf 9)"Not OK"$(tput sgr0)
  sudo unbuffer apt install -y libevent-dev | unbuffer -p grep -E "[0-9]+%" \
    | sed --unbuffered "s/[^0-9]*\([0-9]\+%\).*/"${NC}"\1/" \
    | xargs -I {} echo -n "Installing libevent-dev package ---------------------------------- {}   " $'\r' \
    && echo -e "Installing libevent-dev package ---------------------------------- "$(tput setaf 2)"OK   "$(tput sgr0)
else
  echo -e $(tput setaf 2)"OK   "$(tput sgr0)
fi

[ $? -ne 0 ] && echo -e "Installing libevent-dev package ---------------------------------- "$(tput setaf 9)"Not OK"$(tput sgr0) && return 1

echo -n "Checking gcc installation ---------------------------------------- "
if [ $(which gcc | wc -l) -eq 0 ]; then
  echo -e $(tput setaf 9)"Not OK"$(tput sgr0)
  sudo unbuffer apt install -y build-essential \
    | unbuffer -p grep -E "[0-9]+%" \
    | sed --unbuffered "s/[^0-9]*\([0-9]\+%\).*/"${NC}"\1/" \
    | xargs -I {} echo -n "Installing build-essential package ------------------------------- {}   " $'\r' \
    && echo -e "Installing build-essential package ------------------------------- "$(tput setaf 2)"OK   "$(tput sgr0)
else
  echo -e $(tput setaf 2)"OK   "$(tput sgr0)
fi

[ $? -ne 0 ] && echo -e "Installing build-essential package ------------------------------- "$(tput setaf 9)"Not OK"$(tput sgr0) && return 1

echo -n "Checking yacc installation --------------------------------------- "
if [ $(which yacc | wc -l) -eq 0 ]; then
  echo -e $(tput setaf 9)"Not OK"$(tput sgr0)
  sudo unbuffer apt install -y bison | unbuffer -p grep -E "[0-9]+%" \
    | sed --unbuffered "s/[^0-9]*\([0-9]\+%\).*/"${NC}"\1/" \
    | xargs -I {} echo -n "Installing bison package ----------------------------------------- {}   " $'\r' \
    && echo -e "Installing bison package ----------------------------------------- "$(tput setaf 2)"OK   "$(tput sgr0)
else
  echo -e $(tput setaf 2)"OK   "$(tput sgr0)
fi

[ $? -ne 0 ] && echo -e "Installing bison package ----------------------------------------- "$(tput setaf 9)"Not OK"$(tput sgr0) && return 1

echo -n "Checking make installation --------------------------------------- "
if [ $(which make | wc -l) -eq 0 ]; then
  echo -e $(tput setaf 9)"Not OK"$(tput sgr0)
  sudo unbuffer apt install -y make | unbuffer -p grep -E "[0-9]+%" \
    | sed --unbuffered "s/[^0-9]*\([0-9]\+%\).*/"${NC}"\1/" \
    | xargs -I {} echo -n "Installing make package ------------------------------------------ {}   " $'\r' \
    && echo -e "Installing make package ------------------------------------------ "$(tput setaf 2)"OK   "$(tput sgr0)
else
  echo -e $(tput setaf 2)"OK   "$(tput sgr0)
fi

[ $? -ne 0 ] && echo -e "Installing make package ------------------------------------------ "$(tput setaf 9)"Not OK"$(tput sgr0) && return 1

echo -n "Checking automake installation ----------------------------------- "
if [ $(dpkg -l | command grep -E "automake" | wc -l) -eq 0 ]; then
  echo -e $(tput setaf 9)"Not OK"$(tput sgr0)
  sudo unbuffer apt install -y automake | unbuffer -p grep -E "[0-9]+%" \
    | sed --unbuffered "s/[^0-9]*\([0-9]\+%\).*/"${NC}"\1/" \
    | xargs -I {} echo -n "Installing automake package -------------------------------------- {}   " $'\r' \
    && echo -e "Installing automake package -------------------------------------- "$(tput setaf 2)"OK   "$(tput sgr0)
else
  echo -e $(tput setaf 2)"OK   "$(tput sgr0)
fi

[ $? -ne 0 ] && echo -e "Installing automake package -------------------------------------- "$(tput setaf 9)"Not OK"$(tput sgr0) && return 1

echo -n "Checking autoconf installation ----------------------------------- "
if [ $(dpkg -l | command grep -E "autoconf" | wc -l) -eq 0 ]; then
  echo -e $(tput setaf 9)"Not OK"$(tput sgr0)
  sudo unbuffer apt install -y autoconf | unbuffer -p grep -E "[0-9]+%" \
    | sed --unbuffered "s/[^0-9]*\([0-9]\+%\).*/"${NC}"\1/" \
    | xargs -I {} echo -n "Installing autoconf package -------------------------------------- {}   " $'\r' \
    && echo -e "Installing autoconf package -------------------------------------- "$(tput setaf 2)"OK   "$(tput sgr0)
else
  echo -e $(tput setaf 2)"OK   "$(tput sgr0)
fi

[ $? -ne 0 ] && echo -e "Installing autoconf package -------------------------------------- "$(tput setaf 9)"Not OK"$(tput sgr0) && return 1

echo -n "Checking pkg-config installation --------------------------------- "
if [ $(dpkg -l | command grep -E "pkg-config" | wc -l) -eq 0 ]; then
  echo -e $(tput setaf 9)"Not OK"$(tput sgr0)
  sudo unbuffer apt install -y pkg-config | unbuffer -p grep -E "[0-9]+%" \
    | sed --unbuffered "s/[^0-9]*\([0-9]\+%\).*/"${NC}"\1/" \
    | xargs -I {} echo -n "Installing pkg-config package ------------------------------------ {}   " $'\r' \
    && echo -e "Installing pkg-config package ------------------------------------ "$(tput setaf 2)"OK   "$(tput sgr0)
else
  echo -e $(tput setaf 2)"OK   "$(tput sgr0)
fi

[ $? -ne 0 ] && echo -e "Installing pkg-config package ------------------------------------ "$(tput setaf 9)"Not OK"$(tput sgr0) && return 1

if [ ${GNOME} -eq 1 ]; then
  echo -n "Checking redshift installation ----------------------------------- "
  if [ $(which redshift | wc -l) -eq 0 ]; then
    echo -e $(tput setaf 9)"Not OK"$(tput sgr0)
    sudo unbuffer apt install -y redshift | unbuffer -p grep -E "[0-9]+%" \
      | sed --unbuffered "s/[^0-9]*\([0-9]\+%\).*/"${NC}"\1/" \
      | xargs -I {} echo -n "Installing redshift package -------------------------------------- {}   " $'\r' \
      && echo -e "Installing redshift package -------------------------------------- "$(tput setaf 2)"OK   "$(tput sgr0)
  else
    echo -e $(tput setaf 2)"OK   "$(tput sgr0)
  fi

  [ $? -ne 0 ] && echo -e "Installing redshift package -------------------------------------- "$(tput setaf 9)"Not OK"$(tput sgr0) && return 1
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
  | unbuffer -p grep -E "[0-9]+%" \
  | sed --unbuffered "s/[^0-9]*\([0-9]\+%\).*/"${NC}"\1/" \
  | xargs -I {} echo -n "Cloning VIM repository ------------------------------------------- {}   " $'\r' \
  && echo -e "Cloning VIM repository ------------------------------------------- "$(tput setaf 2)"OK   "$(tput sgr0)

[ $? -ne 0 ] && echo -e "Cloning VIM repository ------------------------------------------- "$(tput setaf 9)"Not OK"$(tput sgr0) \
  && sudo \rm -rf ${CLONE_DIR} && return 1

command cd ${CLONE_DIR}/vim/src
echo -n "Configuring VIM -------------------------------------------------- "
./configure &> /dev/null && echo -e $(tput setaf 2)"OK   "$(tput sgr0)

[ $? -ne 0 ] && echo -e $(tput setaf 9)"Not OK"$(tput sgr0) \
  && command cd ${BACKUP} && sudo \rm -rf ${CLONE_DIR} && return 1

echo -n "Making VIM ------------------------------------------------------- "
make &> /dev/null && echo -e $(tput setaf 2)"OK   "$(tput sgr0)

[ $? -ne 0 ] && echo -e $(tput setaf 9)"Not OK"$(tput sgr0) \
  && command cd ${BACKUP} && sudo \rm -rf ${CLONE_DIR} && return 1

echo -n "Installing VIM --------------------------------------------------- "
sudo make install &> /dev/null && echo -e $(tput setaf 2)"OK   "$(tput sgr0)

[ $? -ne 0 ] && echo -e $(tput setaf 9)"Not OK"$(tput sgr0) \
  && command cd ${BACKUP} && sudo \rm -rf ${CLONE_DIR} && return 1

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
  | unbuffer -p grep -E "[0-9]+%" \
  | sed --unbuffered "s/[^0-9]*\([0-9]\+%\).*/"${NC}"\1/" \
  | xargs -I {} echo -n "Cloning TMUX repository ------------------------------------------ {}   " $'\r' \
  && echo -e "Cloning TMUX repository ------------------------------------------ "$(tput setaf 2)"OK   "$(tput sgr0)

[ $? -ne 0 ] && echo -e "Cloning TMUX repository ------------------------------------------ "$(tput setaf 9)"Not OK"$(tput sgr0) \
  && command cd ${BACKUP} && sudo \rm -rf ${CLONE_DIR} && return 1

echo -n "Configuring TMUX ------------------------------------------------- "
command cd ${CLONE_DIR}/tmux && sh autogen.sh &> /dev/null
./configure &> /dev/null && echo -e $(tput setaf 2)"OK   "$(tput sgr0)

[ $? -ne 0 ] && echo -e $(tput setaf 9)"Not OK"$(tput sgr0) \
  && command cd ${BACKUP} && sudo \rm -rf ${CLONE_DIR} && return 1

echo -n "Making TMUX ------------------------------------------------------ "
make &> /dev/null && echo -e $(tput setaf 2)"OK   "$(tput sgr0)

[ $? -ne 0 ] && echo -e $(tput setaf 9)"Not OK"$(tput sgr0) \
  && command cd ${BACKUP} && sudo \rm -rf ${CLONE_DIR} && return 1

echo -n "Installing TMUX -------------------------------------------------- "
sudo make install &> /dev/null && echo -e $(tput setaf 2)"OK   "$(tput sgr0)

[ $? -ne 0 ] && echo -e $(tput setaf 9)"Not OK"$(tput sgr0) \
  && command cd ${BACKUP} && sudo \rm -rf ${CLONE_DIR} && return 1

echo -e "\n"$(tmux -V)"\n"

TPM_DEST="${HOME}/.tmux/plugins/tpm"
[ -d ${TPM_DEST} ] && sudo \rm -rf ${TPM_DEST}
unbuffer git clone https://github.com/tmux-plugins/tpm ${TPM_DEST} \
  | unbuffer -p grep -E "[0-9]+%" \
  | sed --unbuffered "s/[^0-9]*\([0-9]\+%\).*/"${NC}"\1/" \
  | xargs -I {} echo -n "Cloning TMUX Plugin Manager repository --------------------------- {}   " $'\r' \
  && echo -e "Cloning TMUX Plugin Manager repository --------------------------- "$(tput setaf 2)"OK   "$(tput sgr0)

[ $? -ne 0 ] && echo -e "Cloning TMUX Plugin Manager repository --------------------------- "$(tput setaf 9)"Not OK"$(tput sgr0) \
  && command cd ${BACKUP} && sudo \rm -rf ${CLONE_DIR} && return 1

if [ ${GNOME} -eq 1 ]; then
  EXECUTOR_DEST="${HOME}/.local/share/gnome-shell"
  EXECUTOR_DEST+="/extensions/executor@raujonas.github.io/"
  [ -d ${EXECUTOR_DEST} ] && sudo \rm -rf ${EXECUTOR_DEST}
  unbuffer git clone https://github.com/raujonas/executor.git ${EXECUTOR_DEST} \
    | unbuffer -p grep -E "[0-9]+%" \
    | sed --unbuffered "s/[^0-9]*\([0-9]\+%\).*/"${NC}"\1/" \
    | xargs -I {} echo -n "Cloning EXECUTOR repository -------------------------------------- {}   " $'\r' \
    && echo -e "Cloning EXECUTOR repository -------------------------------------- "$(tput setaf 2)"OK   "$(tput sgr0)

  [ $? -ne 0 ] && echo -e "Cloning EXECUTOR repository -------------------------------------- "$(tput setaf 9)"Not OK"$(tput sgr0) \
    && command cd ${BACKUP} && sudo \rm -rf ${CLONE_DIR} && return 1
fi

command cd ${SCRIPT_DIR} && sudo \rm -rf ${CLONE_DIR}

echo -n "Copying .vimrc --------------------------------------------------- "
command cp vim/.vimrc ${HOME} &> /dev/null \
  && echo -e $(tput setaf 2)"OK   "$(tput sgr0)

[ $? -ne 0 ] && echo -e $(tput setaf 9)"Not OK"$(tput sgr0) \
  && command cd ${BACKUP} && return 1

echo -n "Copying .tmux.conf ----------------------------------------------- "
command cp tmux/.tmux.conf ${HOME} &> /dev/null \
  && echo -e $(tput setaf 2)"OK   "$(tput sgr0)

[ $? -ne 0 ] && echo -e $(tput setaf 9)"Not OK"$(tput sgr0) \
  && command cd ${BACKUP} && return 1

echo -n "Installing TMUX Plugins ------------------------------------------ "
${HOME}/.tmux/plugins/tpm/bin/install_plugins &> /dev/null \
  && echo -e $(tput setaf 2)"OK   "$(tput sgr0)

[ $? -ne 0 ] && echo -e $(tput setaf 9)"Not OK"$(tput sgr0) \
  && command cd ${BACKUP} && return 1

echo -n "Copying .bashrc -------------------------------------------------- "
command cp /etc/skel/.bashrc ${HOME} &> /dev/null \
  && echo -e "\n$(cat bash/.bashrc/basic_settings)" >> ${HOME}/.bashrc \
  && [ ${GNOME} -eq 1 ] && echo -e "\n$(cat bash/.bashrc/redshift_settings)" \
    >> ${HOME}/.bashrc

if [ $? -ne 0 ]; then
  echo -e $(tput setaf 9)"Not OK"$(tput sgr0) && command cd ${BACKUP} \
    && return 1
else
  echo -e $(tput setaf 2)"OK   "$(tput sgr0)
fi

echo -n "Copying .bash_profile -------------------------------------------- "
command cp bash/.bash_profile ${HOME} &> /dev/null \
  && echo -e $(tput setaf 2)"OK   "$(tput sgr0)

[ $? -ne 0 ] && echo -e $(tput setaf 9)"Not OK"$(tput sgr0) \
  && command cd ${BACKUP} && return 1

echo -n "Copying .bash_aliases -------------------------------------------- "
command cp bash/.bash_aliases/usual ${HOME}/.bash_aliases &> /dev/null \
  && echo -e $(tput setaf 2)"OK   "$(tput sgr0)

[ $? -ne 0 ] && echo -e $(tput setaf 9)"Not OK"$(tput sgr0) \
  && command cd ${BACKUP} && return 1

GIT_TEMPLATE_DIR="/usr/share/git-core/templates"
echo -n "Copying .gitignore ----------------------------------------------- "
sudo \cp git/.gitignore ${GIT_TEMPLATE_DIR} &> /dev/null \
  && echo -e $(tput setaf 2)"OK   "$(tput sgr0)

[ $? -ne 0 ] && echo -e $(tput setaf 9)"Not OK"$(tput sgr0) \
  && command cd ${BACKUP} && return 1

echo -n "Copying GIT hooks ------------------------------------------------ "
sudo \cp -r git/.hooks ${GIT_TEMPLATE_DIR} &> /dev/null \
  && echo -e $(tput setaf 2)"OK   "$(tput sgr0)

[ $? -ne 0 ] && echo -e $(tput setaf 9)"Not OK"$(tput sgr0) \
  && command cd ${BACKUP} && return 1

if [ ${GNOME} -eq 1 ]; then
  echo -n "Copying executor scripts ----------------------------------------- "
  [ -d ${HOME}/.executor ] && sudo \rm -rf ${HOME}/.executor
  command cp -r executor ${HOME}/.executor &> /dev/null \
    && echo -e $(tput setaf 2)"OK   "$(tput sgr0)

  [ $? -ne 0 ] && echo -e $(tput setaf 9)"Not OK"$(tput sgr0) \
    && command cd ${BACKUP} && return 1

  echo -n "Enabling EXECUTOR ------------------------------------------------ "
  gnome-extensions enable executor@raujonas.github.io \
    && echo -e $(tput setaf 2)"OK   "$(tput sgr0)

  [ $? -ne 0 ] && echo -e $(tput setaf 9)"Not OK"$(tput sgr0) \
    && command cd ${BACKUP} && return 1

  echo -n "Restarting GNOME ------------------------------------------------- "
  killall -3 gnome-shell &> /dev/null \
    && echo -e $(tput setaf 2)"OK   "$(tput sgr0)

  [ $? -ne 0 ] && echo -e $(tput setaf 9)"Not OK"$(tput sgr0) \
    && command cd ${BACKUP} && return 1

  echo -n -e "\nPress Enter when GNOME service is functional again " \
    && read && echo
fi

echo -n "Disabling bluetooth by default ----------------------------------- "
sudo systemctl disable bluetooth.service &> /dev/null \
  && echo -e $(tput setaf 2)"OK   "$(tput sgr0)

[ $? -ne 0 ] && echo -e $(tput setaf 9)"Not OK"$(tput sgr0) \
  && command cd ${BACKUP} && return 1

echo -n "Sourcing .bashrc ------------------------------------------------- "
source ${HOME}/.bashrc &> /dev/null && echo -e $(tput setaf 2)"OK   "$(tput sgr0)

[ $? -ne 0 ] && echo -e $(tput setaf 9)"Not OK"$(tput sgr0) \
  && command cd ${BACKUP} && return 1

command cd ${BACKUP}
