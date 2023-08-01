# NOTE: PATH specified in $HOME/.MacOSX/environment.plist
#       so that Emacs will have correct path when not launched from terminal
# PATH="/Applications/Emacs.app/Contents/MacOS:${PATH}"
PATH="/Applications/Emacs.app/Contents/MacOS/bin:${PATH}"
# PATH="/Applications/MATLAB_R2013a.app/bin:${PATH}"
# PATH="/Applications/Julia-0.2.1.app/Contents/Resources/julia/bin:${PATH}"
# PATH="$HOME/anaconda3/bin:${PATH}"
# PATH="/Developer/NVIDIA/CUDA-6.5/bin:${PATH}"
# PATH="/usr/local/bin:${PATH}"
# PATH=/usr/local/visit/bin:${PATH}
# PATH="/usr/texbin:${PATH}"
# PATH="/Library/Frameworks/EPD64.framework/Versions/Current/bin:${PATH}"
# PATH="/Developer/usr/bin:${PATH}"
# PATH="/Applications/sage:${PATH}"
# PATH="/usr/local/git/bin:${PATH}"
PATH="$HOME/Documents/logue/logue-sdk/tools/logue-cli/logue-cli-osx-0.07-2b:${PATH}"
PATH="$HOME/bin:${PATH}"
export PATH

# export DYLD_LIBRARY_PATH=/Developer/NVIDIA/CUDA-6.5/lib:$DYLD_LIBRARY_PATH

export MANPATH="/opt/local/man:/usr/local/man:/usr/local/mysql/man:${MANPATH}"

export INFOPATH="$HOME/lib/info"

# export PYTHONPATH="$HOME/lib/python:/Library/Frameworks/EPD64.framework/Versions/Current/lib/python2.7/site-packages"
# export PYTHONPATH="$HOME/Local/Consulting/Blood Volume/python:${PYTHONPATH}"
# export PYTHONPATH="$HOME/Work/Projects/pycontrol"

# export SAGE_ROOT="/Applications/sage"
# export LIBRARY_PATH="${SAGE_ROOT}/local/lib"
# export LD_LIBRARY_PATH="${SAGE_ROOT}/local/lib"
# export DYLD_LIBRARY_PATH="${SAGE_ROOT}/local/lib"

export LC_CTYPE=en_US.UTF-8

export DISPLAY=${DISPLAY:=":0.0"}

# don't include extended attributes (._*) in tar files
export COPYFILE_DISABLE=true
export BASH_SILENCE_DEPRECATION_WARNING=1
BREW=/opt/homebrew/bin/brew
if [ -x "$BREW" ]; then
	eval "$($BREW shellenv)"
fi

