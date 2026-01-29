#!/bin/bash

dirs="bash conda emacs git python tex tmux"

pushd emacs/.emacs.d && make && popd
[ ! -d ../.emacs.d ] && mkdir ../.emacs.d
stow --dotfiles --ignore=NO --ignore=Makefile $dirs

