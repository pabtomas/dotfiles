#!/bin/bash

DIR=/tmp/vim_repo_clone
BACKUP=$(pwd)

[ -d $DIR ] && rm -rf $DIR
mkdir -p $DIR && cd $DIR
git clone https://github.com/vim/vim.git

if [ $(dpkg -l | grep -E "libncurses-dev" | wc -l) -eq 0 ]; then
  sudo apt install libncurses-dev
fi
if [ $(which gcc | wc -l) -eq 0 ]; then
  sudo apt install build-essential
fi

cd vim/src
./configure && make && sudo make install

cd $BACKUP && rm -rf $DIR
source ~/.bashrc && clear && vim --version
