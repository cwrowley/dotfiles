# Loaded by venv completion scripts to provide _venv_globals_array.
: "${VENV_HOME:=$HOME/.pyenv}"

_venv_globals_array() {
    reply=( "$VENV_HOME"/*(/N:t) )
}
