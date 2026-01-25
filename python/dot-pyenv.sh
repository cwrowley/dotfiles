export VENV_HOME="${VENV_HOME:-"$HOME/.pyenv"}"

# -----------------------
# Internal helpers
# -----------------------

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
    local path="$1"
    if _venv_has_uv; then
        uv venv -- "$path"
    else
        local py
        py="$(_venv_python_cmd)" || { echo "Error: neither 'uv' nor 'python/python3' found in PATH"; return 127; }
        "$py" -m venv -- "$path"
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
        echo "Error: missing activation script: $act"
        return 1
    fi
}

# List global env names (directories under VENV_HOME)
_venv_list_globals() {
    [[ -d "$VENV_HOME" ]] || return 0
    shopt -s nullglob
    local d
    for d in "$VENV_HOME"/*/; do
        printf '%s\n' "$(basename "${d%/}")"
    done
    shopt -u nullglob
}

# -----------------------
# Public commands
# -----------------------

lsenv() {
    if [[ ! -d "$VENV_HOME" ]]; then
        echo "No global env directory: $VENV_HOME"
        return 0
    fi
    echo "Available environments in $VENV_HOME:"
    local any=false
    while IFS= read -r name; do
        any=true
        printf '%s\n' "$name"
    done < <(_venv_list_globals)
    $any || echo "(none)"
}

mkenv() {
    local global_env=false opt OPTIND
    while getopts ":g" opt; do
        case "$opt" in
            g) global_env=true ;;
            *)
                echo "Usage: mkenv [-g] [env_name]"
                return 1
                ;;
        esac
    done
    shift $((OPTIND - 1))

    if $global_env; then
        if [[ -z "${1:-}" ]]; then
            echo "Usage: mkenv -g <env_name>"
            lsenv
            return 1
        fi
        mkdir -p -- "$VENV_HOME" || return 1

        echo "Making new global environment: $1"
        _venv_create_at "$VENV_HOME/$1" || return 1
        _venv_source_activate "$VENV_HOME/$1"
    else
        if [[ -z "${1:-}" ]]; then
            echo "Making new default environment in current directory"
            _venv_create_default_local || return 1

            # Prefer .venv, but keep fallback to venv if present
            if [[ -d ".venv" ]]; then
                _venv_source_activate ".venv"
            elif [[ -d "venv" ]]; then
                _venv_source_activate "venv"
            else
                echo "Error: venv created, but could not locate .venv/ or venv/ for activation."
                return 1
            fi
        else
            echo "Making new environment '$1' in current directory"
            _venv_create_at "$1" || return 1
            _venv_source_activate "$1"
        fi
    fi
}

activate() {
    local env requested

    # No args => try local defaults
    if [[ -z "${1:-}" ]]; then
        for dir in .venv venv; do
            if [[ -d "$dir" && -f "$dir/bin/activate" ]]; then
                env="$dir"
                requested="$dir"
                break
            fi
        done
        if [[ -z "${env:-}" ]]; then
            echo "Default local environment not found (looked for .venv/ and venv/)."
            return 1
        fi
        _venv_source_activate "$env"
        return
    fi

    # With args
    if [[ "$1" == "-g" ]]; then
        shift
        if [[ -z "${1:-}" ]]; then
            lsenv
            return 0
        fi
        requested="$1"
        env="$VENV_HOME/$1"
    else
        requested="$1"
        env="$1"
    fi

    if [[ -d "$env" ]]; then
        _venv_source_activate "$env"
    else
        echo "Error: environment '$requested' not found."
        return 1
    fi
}

rmenv() {
    local global_env=false force=false opt OPTIND
    while getopts ":gf" opt; do
        case "$opt" in
            g) global_env=true ;;
            f) force=true ;;
            *)
                echo "Usage: rmenv [-g] [-f] <env_name_or_path>"
                return 1
                ;;
        esac
    done
    shift $((OPTIND - 1))

    if [[ -z "${1:-}" ]]; then
        echo "Usage: rmenv [-g] [-f] <env_name_or_path>"
        $global_env && lsenv
        return 1
    fi

    local target
    if $global_env; then
        target="$VENV_HOME/$1"
    else
        target="$1"
    fi

    if [[ ! -d "$target" ]]; then
        echo "Error: not a directory: $target"
        return 1
    fi

    # Safety: require it to look like a venv (pyvenv.cfg is standard)
    if [[ ! -f "$target/pyvenv.cfg" ]]; then
        echo "Refusing to remove '$target' (missing pyvenv.cfg; doesn't look like a venv)."
        return 1
    fi

    if ! $force; then
        local reply
        read -r -p "Remove virtual environment '$target'? [y/N] " reply
        [[ "$reply" =~ ^[Yy]$ ]] || { echo "Cancelled."; return 1; }
    fi

    rm -rf -- "$target"
    echo "Removed: $target"
}


# -----------------------
# Bash completion
# -----------------------

_activate_completion() {
    local cur prev
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # Complete option flags at position 1
    if (( COMP_CWORD == 1 )); then
        COMPREPLY=($(compgen -W "-g" -- "$cur"))
        # Also suggest common local env dirs
        COMPREPLY+=($(compgen -W ".venv venv" -- "$cur"))
        return 0
    fi

    # If completing after -g, list global envs
    if [[ "$prev" == "-g" ]]; then
        local globals
        globals="$(_venv_list_globals 2>/dev/null)"
        COMPREPLY=($(compgen -W "$globals" -- "$cur"))
        return 0
    fi

    # Otherwise, complete directories in cwd
    COMPREPLY=($(compgen -d -- "$cur"))
    # And suggest common local env dirs
    COMPREPLY+=($(compgen -W ".venv venv" -- "$cur"))
}

_mkenv_completion() {
    local cur prev
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    if (( COMP_CWORD == 1 )); then
        COMPREPLY=($(compgen -W "-g" -- "$cur"))
        return 0
    fi

    # If -g is present, complete with existing globals (nice for avoiding typos)
    if [[ "${COMP_WORDS[*]}" == *" -g "* ]]; then
        local globals
        globals="$(_venv_list_globals 2>/dev/null)"
        COMPREPLY=($(compgen -W "$globals" -- "$cur"))
        return 0
    fi

    COMPREPLY=()
}

_rmenv_completion() {
    local cur prev
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    if (( COMP_CWORD == 1 )); then
        COMPREPLY=($(compgen -W "-g -f" -- "$cur"))
        return 0
    fi

    # If completing after -g, offer global env names
    if [[ "$prev" == "-g" ]] || [[ "${COMP_WORDS[*]}" == *" -g "* ]]; then
        local globals
        globals="$(_venv_list_globals 2>/dev/null)"
        COMPREPLY=($(compgen -W "$globals" -- "$cur"))
        return 0
    fi

    # Otherwise complete directories
    COMPREPLY=($(compgen -d -- "$cur"))
}

# Register completions
complete -F _activate_completion activate
complete -F _mkenv_completion mkenv
complete -F _rmenv_completion rmenv

