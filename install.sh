#!/bin/bash

pushd emacs/.emacs.d && make && popd
[ ! -d ../.emacs.d ] && mkdir ../.emacs.d
stow --dotfiles --ignore=Makefile bash conda emacs git python

