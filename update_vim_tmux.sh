#!/bin/bash

CLONE_DIR=/tmp/repositories_clone
BACKUP=$(pwd)

VIM_VERSION="-> "
TMUX_VERSION="-> "

if [ $(which vim | wc -l) -eq 1 ]; then
  VIM_VERSION="vim "$(vim --version | head -n 2 | sed "s/^[^0-9]\+//" \
    | sed "s/ (.*$//g" | sed "s/^[0-9]\+-//" | tr '\n' '.    ' \
    | sed "s/\.$/\n/")" -> vim "
fi

if [ $(which tmux | wc -l) -eq 1 ]; then
  TMUX_VERSION=$(tmux -V)" -> "
fi

if [ $(which git | wc -l) -eq 0 ]; then
  sudo apt install git
fi

# cloning repositories
[ -d ${CLONE_DIR} ] && rm -rf ${CLONE_DIR}
mkdir -p ${CLONE_DIR} && cd ${CLONE_DIR}
git clone https://github.com/vim/vim.git
git clone https://github.com/tmux/tmux.git

# install dependencies
if [ $(dpkg -l | grep -E "libncurses-dev" | wc -l) -eq 0 ]; then
  sudo apt install libncurses-dev
fi
if [ $(dpkg -l | grep -E "libevent-dev" | wc -l) -eq 0 ]; then
  sudo apt install libevent-dev
fi
if [ $(dpkg -l | grep -E "automake" | wc -l) -eq 0 ]; then
  sudo apt install automake
fi
if [ $(dpkg -l | grep -E "autoconf" | wc -l) -eq 0 ]; then
  sudo apt install autoconf
fi
if [ $(dpkg -l | grep -E "pkg-config" | wc -l) -eq 0 ]; then
  sudo apt install pkg-config
fi
if [ $(which gcc | wc -l) -eq 0 ]; then
  sudo apt install build-essential
fi
if [ $(which yacc | wc -l) -eq 0 ]; then
  sudo apt install bison
fi

# VIM installation
cd ${CLONE_DIR}/vim/src
./configure && make && sudo make install

# TMUX installation
cd ${CLONE_DIR}/tmux && sh autogen.sh
./configure && make && sudo make install

cd ${BACKUP} && rm -rf ${CLONE_DIR}

source ~/.bashrc && clear && echo -e ${VIM_VERSION}"$(vim --version \
  | head -n 2 | sed "s/^[^0-9]\+//" | sed "s/ (.*$//g" | sed "s/^[0-9]\+-//" \
  | tr '\n' '.    ' | sed "s/\.$/\n/")\n"${TMUX_VERSION}$(tmux -V)
