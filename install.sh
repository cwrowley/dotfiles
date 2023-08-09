#!/bin/bash

dirs="bash conda emacs git python tex"

pushd emacs/.emacs.d && make && popd
[ ! -d ../.emacs.d ] && mkdir ../.emacs.d
stow --dotfiles --ignore=Makefile $dirs

