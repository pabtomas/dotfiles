#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root" && exit 1
fi

CLONE_DIR=/tmp/repositories_clone
BACKUP=$(pwd)

[ -d ${CLONE_DIR} ] && command rm -rf ${CLONE_DIR}
command mkdir -p ${CLONE_DIR} && command cd ${CLONE_DIR}

echo -n "Updating system -------------------------------------------------- "
sudo apt update -y > /dev/null 2>&1 && echo $(tput setaf 2)"OK"$(tput sgr0)

[ $? -ne 0 ] && echo $(tput setaf 9)"Not OK"$(tput sgr0) \
  && command cd ${BACKUP} && command rm -rf ${CLONE_DIR} && exit 1

echo -n "Upgrading system ------------------------------------------------- "
sudo apt upgrade -y > /dev/null 2>&1 && echo $(tput setaf 2)"OK"$(tput sgr0)

[ $? -ne 0 ] && echo $(tput setaf 9)"Not OK"$(tput sgr0) \
  && command cd ${BACKUP} && command rm -rf ${CLONE_DIR} && exit 1

echo -n "Removing unused packages ----------------------------------------- "
sudo apt autoremove -y > /dev/null 2>&1 \
  && echo $(tput setaf 2)"OK"$(tput sgr0)

[ $? -ne 0 ] && echo $(tput setaf 9)"Not OK"$(tput sgr0) \
  && command cd ${BACKUP} && command rm -rf ${CLONE_DIR} && exit 1

echo -n "Checking GIT installation ---------------------------------------- "
if [ $(which git | wc -l) -eq 0 ]; then
  echo $(tput setaf 9)"Not OK"$(tput sgr0)
  echo -n "Installing GIT package ------------------------------------------- "
  sudo apt install -y git > /dev/null 2>&1 \
    && echo $(tput setaf 2)"OK"$(tput sgr0)
else
  echo $(tput setaf 2)"OK"$(tput sgr0)
fi

[ $? -ne 0 ] && echo $(tput setaf 9)"Not OK"$(tput sgr0) \
  && command cd ${BACKUP} && command rm -rf ${CLONE_DIR} && exit 1

echo -n "Checking libncurses-dev installation ----------------------------- "
if [ $(dpkg -l | command grep -E "libncurses-dev" | wc -l) -eq 0 ]; then
  echo $(tput setaf 9)"Not OK"$(tput sgr0)
  echo -n "Installing libncurses-dev package -------------------------------- "
  sudo apt install -y libncurses-dev > /dev/null 2>&1 \
    && echo $(tput setaf 2)"OK"$(tput sgr0)
else
  echo $(tput setaf 2)"OK"$(tput sgr0)
fi

[ $? -ne 0 ] && echo $(tput setaf 9)"Not OK"$(tput sgr0) \
  && command cd ${BACKUP} && command rm -rf ${CLONE_DIR} && exit 1

echo -n "Checking libevent-dev installation ------------------------------- "
if [ $(dpkg -l | command grep -E "libevent-dev" | wc -l) -eq 0 ]; then
  echo $(tput setaf 9)"Not OK"$(tput sgr0)
  echo -n "Installing libevent-dev package ---------------------------------- "
  sudo apt install -y libevent-dev > /dev/null 2>&1 \
    && echo $(tput setaf 2)"OK"$(tput sgr0)
else
  echo $(tput setaf 2)"OK"$(tput sgr0)
fi

[ $? -ne 0 ] && echo $(tput setaf 9)"Not OK"$(tput sgr0) \
  && command cd ${BACKUP} && command rm -rf ${CLONE_DIR} && exit 1

echo -n "Checking gcc installation ---------------------------------------- "
if [ $(which gcc | wc -l) -eq 0 ]; then
  echo $(tput setaf 9)"Not OK"$(tput sgr0)
  echo -n "Installing build-essential package ------------------------------- "
  sudo apt install -y build-essential > /dev/null 2>&1 \
    && echo $(tput setaf 2)"OK"$(tput sgr0)
else
  echo $(tput setaf 2)"OK"$(tput sgr0)
fi

[ $? -ne 0 ] && echo $(tput setaf 9)"Not OK"$(tput sgr0) \
  && command cd ${BACKUP} && command rm -rf ${CLONE_DIR} && exit 1

echo -n "Checking yacc installation --------------------------------------- "
if [ $(which yacc | wc -l) -eq 0 ]; then
  echo $(tput setaf 9)"Not OK"$(tput sgr0)
  echo -n "Installing bison package ----------------------------------------- "
  sudo apt install -y bison > /dev/null 2>&1 \
    && echo $(tput setaf 2)"OK"$(tput sgr0)
else
  echo $(tput setaf 2)"OK"$(tput sgr0)
fi

[ $? -ne 0 ] && echo $(tput setaf 9)"Not OK"$(tput sgr0) \
  && command cd ${BACKUP} && command rm -rf ${CLONE_DIR} && exit 1

echo -n "Checking make installation --------------------------------------- "
if [ $(which make | wc -l) -eq 0 ]; then
  echo $(tput setaf 9)"Not OK"$(tput sgr0)
  echo -n "Installing make package ------------------------------------------ "
  sudo apt install -y make > /dev/null 2>&1 \
    && echo $(tput setaf 2)"OK"$(tput sgr0)
else
  echo $(tput setaf 2)"OK"$(tput sgr0)
fi

[ $? -ne 0 ] && echo $(tput setaf 9)"Not OK"$(tput sgr0) \
  && command cd ${BACKUP} && command rm -rf ${CLONE_DIR} && exit 1

echo -n "Checking automake installation ----------------------------------- "
if [ $(dpkg -l | command grep -E "automake" | wc -l) -eq 0 ]; then
  echo $(tput setaf 9)"Not OK"$(tput sgr0)
  echo -n "Installing automake package -------------------------------------- "
  sudo apt install -y automake > /dev/null 2>&1 \
    && echo $(tput setaf 2)"OK"$(tput sgr0)
else
  echo $(tput setaf 2)"OK"$(tput sgr0)
fi

[ $? -ne 0 ] && echo $(tput setaf 9)"Not OK"$(tput sgr0) \
  && command cd ${BACKUP} && command rm -rf ${CLONE_DIR} && exit 1

echo -n "Checking autoconf installation ----------------------------------- "
if [ $(dpkg -l | command grep -E "autoconf" | wc -l) -eq 0 ]; then
  echo $(tput setaf 9)"Not OK"$(tput sgr0)
  echo -n "Installing autoconf package -------------------------------------- "
  sudo apt install -y autoconf > /dev/null 2>&1 \
    && echo $(tput setaf 2)"OK"$(tput sgr0)
else
  echo $(tput setaf 2)"OK"$(tput sgr0)
fi

[ $? -ne 0 ] && echo $(tput setaf 9)"Not OK"$(tput sgr0) \
  && command cd ${BACKUP} && command rm -rf ${CLONE_DIR} && exit 1

echo -n "Checking pkg-config installation --------------------------------- "
if [ $(dpkg -l | command grep -E "pkg-config" | wc -l) -eq 0 ]; then
  echo $(tput setaf 9)"Not OK"$(tput sgr0)
  echo -n "Installing pkg-config package ------------------------------------ "
  sudo apt install -y pkg-config > /dev/null 2>&1 \
    && echo $(tput setaf 2)"OK"$(tput sgr0)
else
  echo $(tput setaf 2)"OK"$(tput sgr0)
fi

[ $? -ne 0 ] && echo $(tput setaf 9)"Not OK"$(tput sgr0) \
  && command cd ${BACKUP} && command rm -rf ${CLONE_DIR} && exit 1

echo -n "Checking redshift installation ----------------------------------- "
if [ $(which redshift | wc -l) -eq 0 ]; then
  echo $(tput setaf 9)"Not OK"$(tput sgr0)
  echo -n "Installing redshift package -------------------------------------- "
  sudo apt install -y redshift > /dev/null 2>&1 \
    && echo $(tput setaf 2)"OK"$(tput sgr0)
else
  echo $(tput setaf 2)"OK"$(tput sgr0)
fi

[ $? -ne 0 ] && echo $(tput setaf 9)"Not OK"$(tput sgr0) \
  && command cd ${BACKUP} && command rm -rf ${CLONE_DIR} && exit 1

echo -n "Checking VIM version --------------------------------------------- "
if [ $(which vim | wc -l) -eq 1 ]; then
  echo $(tput setaf 2)"OK"$(tput sgr0)
  echo -e "\nvim "$(vim --version | head -n 2 | sed "s/^[^0-9]\+//" \
    | sed "s/ (.*$//g" | sed "s/^[0-9]\+-//" | tr '\n' '.    ' \
    | sed "s/\.$/\n/")"\n"
else
  echo $(tput setaf 9)"Not OK"$(tput sgr0)
fi

echo -n "Cloning VIM repository ------------------------------------------- "
git clone https://github.com/vim/vim.git > /dev/null 2>&1 \
  && echo $(tput setaf 2)"OK"$(tput sgr0)

[ $? -ne 0 ] && echo $(tput setaf 9)"Not OK"$(tput sgr0) \
  && command cd ${BACKUP} && command rm -rf ${CLONE_DIR} && exit 1

command cd ${CLONE_DIR}/vim/src
echo -n "Configuring VIM -------------------------------------------------- "
./configure > /dev/null 2>&1 && echo $(tput setaf 2)"OK"$(tput sgr0)

[ $? -ne 0 ] && echo $(tput setaf 9)"Not OK"$(tput sgr0) \
  && command cd ${BACKUP} && command rm -rf ${CLONE_DIR} && exit 1

echo -n "Making VIM ------------------------------------------------------- "
make > /dev/null 2>&1 && echo $(tput setaf 2)"OK"$(tput sgr0)

[ $? -ne 0 ] && echo $(tput setaf 9)"Not OK"$(tput sgr0) \
  && command cd ${BACKUP} && command rm -rf ${CLONE_DIR} && exit 1

echo -n "Installing VIM --------------------------------------------------- "
sudo make install > /dev/null 2>&1 && echo $(tput setaf 2)"OK"$(tput sgr0)

[ $? -ne 0 ] && echo $(tput setaf 9)"Not OK"$(tput sgr0) \
  && command cd ${BACKUP} && command rm -rf ${CLONE_DIR} && exit 1

echo -e "\nvim "$(vim --version \
  | head -n 2 | sed "s/^[^0-9]\+//" | sed "s/ (.*$//g" | sed "s/^[0-9]\+-//" \
  | tr '\n' '.    ' | sed "s/\.$/\n/")"\n"

echo -n "Checking TMUX version -------------------------------------------- "
if [ $(which tmux | wc -l) -eq 1 ]; then
  echo $(tput setaf 2)"OK"$(tput sgr0)
  echo -e "\n"$(tmux -V)"\n"
else
  echo $(tput setaf 9)"Not OK"$(tput sgr0)
fi

command cd ${CLONE_DIR}
echo -n "Cloning TMUX repository ------------------------------------------ "
git clone https://github.com/tmux/tmux.git > /dev/null 2>&1 \
  && echo $(tput setaf 2)"OK"$(tput sgr0)

[ $? -ne 0 ] && echo $(tput setaf 9)"Not OK"$(tput sgr0) \
  && command cd ${BACKUP} && command rm -rf ${CLONE_DIR} && exit 1

echo -n "Configuring TMUX ------------------------------------------------- "
command cd ${CLONE_DIR}/tmux && sh autogen.sh > /dev/null 2>&1
./configure > /dev/null 2>&1 && echo $(tput setaf 2)"OK"$(tput sgr0)

[ $? -ne 0 ] && echo $(tput setaf 9)"Not OK"$(tput sgr0) \
  && command cd ${BACKUP} && command rm -rf ${CLONE_DIR} && exit 1

echo -n "Making TMUX ------------------------------------------------------ "
make > /dev/null 2>&1 && echo $(tput setaf 2)"OK"$(tput sgr0)

[ $? -ne 0 ] && echo $(tput setaf 9)"Not OK"$(tput sgr0) \
  && command cd ${BACKUP} && command rm -rf ${CLONE_DIR} && exit 1

echo -n "Installing TMUX -------------------------------------------------- "
sudo make install > /dev/null 2>&1 && echo $(tput setaf 2)"OK"$(tput sgr0)

[ $? -ne 0 ] && echo $(tput setaf 9)"Not OK"$(tput sgr0) \
  && command cd ${BACKUP} && command rm -rf ${CLONE_DIR} && exit 1

echo -e "\n"$(tmux -V)"\n"

echo -n "Cloning EXECUTOR repository -------------------------------------- "
USER_HOME="$(getent passwd ${SUDO_USER} | cut -d: -f6)"
EXECUTOR_DEST="${USER_HOME}"\
"/.local/share/gnome-shell/extensions/executor@raujonas.github.io/"
[ -d ${EXECUTOR_DEST} ] && command rm -rf ${EXECUTOR_DEST}
git clone https://github.com/raujonas/executor.git ${EXECUTOR_DEST} > \
  /dev/null 2>&1 && echo $(tput setaf 2)"OK"$(tput sgr0)

[ $? -ne 0 ] && echo $(tput setaf 9)"Not OK"$(tput sgr0) \
  && command cd ${BACKUP} && command rm -rf ${CLONE_DIR} && exit 1

command cd ${BACKUP} && command rm -rf ${CLONE_DIR}

echo -n "Copying .vimrc --------------------------------------------------- "
command cp vim/.vimrc ${USER_HOME} > /dev/null 2>&1 \
  && echo $(tput setaf 2)"OK"$(tput sgr0)

[ $? -ne 0 ] && echo $(tput setaf 9)"Not OK"$(tput sgr0) \
  && command cd ${BACKUP} && command rm -rf ${CLONE_DIR} && exit 1

echo -n "Copying .tmux.conf ----------------------------------------------- "
command cp tmux/.tmux.conf ${USER_HOME} > /dev/null 2>&1 \
  && echo $(tput setaf 2)"OK"$(tput sgr0)

[ $? -ne 0 ] && echo $(tput setaf 9)"Not OK"$(tput sgr0) \
  && command cd ${BACKUP} && command rm -rf ${CLONE_DIR} && exit 1

echo -n "Copying .bashrc -------------------------------------------------- "
command cp /etc/skel/.bashrc ${USER_HOME} > /dev/null 2>&1 \
  && echo -e "\n$(cat bash/.bashrc)" >> \
    ${USER_HOME}/.bashrc && echo $(tput setaf 2)"OK"$(tput sgr0)

[ $? -ne 0 ] && echo $(tput setaf 9)"Not OK"$(tput sgr0) \
  && command cd ${BACKUP} && command rm -rf ${CLONE_DIR} && exit 1

echo -n "Copying .bash_profile -------------------------------------------- "
command cp bash/.bash_profile ${USER_HOME} > /dev/null 2>&1 \
  && echo $(tput setaf 2)"OK"$(tput sgr0)

[ $? -ne 0 ] && echo $(tput setaf 9)"Not OK"$(tput sgr0) \
  && command cd ${BACKUP} && command rm -rf ${CLONE_DIR} && exit 1

echo -n "Copying .bash_aliases -------------------------------------------- "
command cp bash/.bash_aliases ${USER_HOME} > /dev/null 2>&1 \
  && echo $(tput setaf 2)"OK"$(tput sgr0)

[ $? -ne 0 ] && echo $(tput setaf 9)"Not OK"$(tput sgr0) \
  && command cd ${BACKUP} && command rm -rf ${CLONE_DIR} && exit 1

echo -n "Copying executor scripts ----------------------------------------- "
[ -d ${USER_HOME}/.executor ] && command rm -rf ${USER_HOME}/.executor
command cp -r executor ${USER_HOME}/.executor > /dev/null 2>&1 \
  && command rm ${USER_HOME}/.executor/README.md \
  && echo $(tput setaf 2)"OK"$(tput sgr0)

[ $? -ne 0 ] && echo $(tput setaf 9)"Not OK"$(tput sgr0) \
  && command cd ${BACKUP} && command rm -rf ${CLONE_DIR} && exit 1

echo -n "Enabling EXECUTOR ------------------------------------------------ "
gnome-extensions enable executor@raujonas.github.io \
  && echo $(tput setaf 2)"OK"$(tput sgr0)

[ $? -ne 0 ] && echo $(tput setaf 9)"Not OK"$(tput sgr0) \
  && command cd ${BACKUP} && command rm -rf ${CLONE_DIR} && exit 1

echo -n "Restarting Gnome -------------------------------------------------- "
gdbus call --session --dest org.gnome.Shell --object-path /org/gnome/Shell --method org.gnome.Shell.Eval 'Meta.restart(_("Restarting…"))' > /dev/null && echo $(tput setaf 2)"OK"$(tput sgr0)

[ $? -ne 0 ] && echo $(tput setaf 9)"Not OK"$(tput sgr0) \
  && command cd ${BACKUP} && command rm -rf ${CLONE_DIR} && exit 1

echo -e $(tput setaf 3)"\nSource your new .bashrc to complete installation\n"
