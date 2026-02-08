# Shared helpers for python virtual environment tools

# default location for global environments
: "${VENV_HOME:="$HOME/.pyenv"}"

# Guard against double-loading
[[ -n ${_VENV_LIB_LOADED-} ]] && return
_VENV_LIB_LOADED=1

_venv_globals_array() {
  emulate -L zsh
  reply=()
  [[ -d "$VENV_HOME" ]] || return 0

  local d
  for d in "$VENV_HOME"/*(/N); do
    reply+=("${d:t}")
  done
}

_venv_has_uv() { command -v uv >/dev/null 2>&1; }

_venv_python_cmd() {
    if command -v python3 >/dev/null 2>&1; then
        printf '%s\n' python3
    elif command -v python >/dev/null 2>&1; then
        printf '%s\n' python
    else
        return 1
    fi
}

# Create a venv at a given path (or name). Uses uv if available, else python -m venv.
_venv_create_at() {
    emulate -L zsh
    local target="$1"
    if _venv_has_uv; then
        uv venv -- "$target"
    else
        local py
        py="$(_venv_python_cmd)" || { echo "Error: neither 'uv' nor 'python/python3' found in PATH"; return 127; }
        "$py" -m venv -- "$target"
    fi
}

# Create the default local venv.
_venv_create_default_local() {
    if _venv_has_uv; then
        uv venv
    else
        _venv_create_at ".venv"
    fi
}

# Activate from a directory path; verify it looks like a venv.
_venv_source_activate() {
    local envdir="$1"
    local act="$envdir/bin/activate"
    if [[ -f "$act" ]]; then
        source "$act"
    else
        print -r -- "Error: missing activation script: $act"
        return 1
    fi
}
