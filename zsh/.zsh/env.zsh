export PAGER="less -R"
export LESS="-R"
export EDITOR=emacsclient
export ALTERNATE_EDITOR=vi
export HELPDIR=/usr/share/zsh/"${ZSH_VERSION}"/help

export PYTHONSTARTUP="$HOME/.pythonstartup.py"

export PETSC_DIR="$HOME/petsc"
export PETSC_ARCH=arch-darwin-c-opt
export SLEPC_DIR="$HOME/slepc"

# workaround for python -c "import numpy; import torch"
export KMP_DUPLICATE_LIB_OK=TRUE
