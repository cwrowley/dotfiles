#!/bin/bash

dirs="bash conda emacs git python tex tmux zsh"

pushd emacs/.emacs.d && make && popd
[ ! -d ../.emacs.d ] && mkdir ../.emacs.d
mkdir -p ~/.zsh/{completions,lib}
stow --dotfiles --ignore=NO --ignore=Makefile $dirs

