#!/bin/bash

DIR=/tmp/vim_repo_clone

[ -d $DIR ] && rm -rf $DIR
mkdir -p $DIR && cd $DIR
git clone https://github.com/preservim/nerdtree.git
rm -rf ~/.vim/*
cp -r nerdtree/* ~/.vim
git clone https://github.com/vim/vim.git
cd vim/src
./configure && make && sudo make install

cd $DIR && rm -rf $DIR
cd ~
vim --version
