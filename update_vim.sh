#!/bin/bash

DIR=/tmp/vim_repo_clone
BACKUP=$(pwd)

[ -d $DIR ] && rm -rf $DIR
mkdir -p $DIR && cd $DIR
git clone https://github.com/vim/vim.git
cd vim/src
./configure && make && sudo make install

cd $BACKUP && rm -rf $DIR
source ~/.bashrc && clear && vim --version
