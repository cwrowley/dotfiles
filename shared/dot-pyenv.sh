# Python virtual environment tools for bash
# Installed as ~/.pyenv.sh and sourced by ~/.bashrc

: "${VENV_HOME:=$HOME/.pyenv}"

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

_venv_create_at() {
    local target="$1"
    if _venv_has_uv; then
        uv venv -- "$target"
    else
        local py
        py="$(_venv_python_cmd)" || { printf 'Error: neither uv nor python/python3 found in PATH\n' >&2; return 127; }
        "$py" -m venv -- "$target"
    fi
}

_venv_source_activate() {
    local act="$1/bin/activate"
    if [ -f "$act" ]; then
        # shellcheck disable=SC1090
        . "$act"
    else
        printf 'Error: missing activation script: %s\n' "$act" >&2
        return 1
    fi
}

lsenv() {
    if [ ! -d "$VENV_HOME" ]; then
        printf 'No global env directory: %s\n' "$VENV_HOME"
        return 0
    fi
    printf 'Available environments in %s:\n' "$VENV_HOME"
    local found=false d
    for d in "$VENV_HOME"/*/; do
        [ -d "$d" ] || continue
        printf '  %s\n' "$(basename "$d")"
        found=true
    done
    $found || printf '  (none)\n'
}

mkenv() {
    local global_env=false opt
    OPTIND=1
    while getopts ":g" opt; do
        case "$opt" in
            g) global_env=true ;;
            *) printf 'Usage: mkenv [-g] [env_name]\n' >&2; return 1 ;;
        esac
    done
    shift $((OPTIND - 1))

    if $global_env; then
        [ -n "${1-}" ] || { printf 'Usage: mkenv -g <env_name>\n' >&2; lsenv; return 1; }
        mkdir -p -- "$VENV_HOME" || return 1
        printf 'Making new global environment: %s\n' "$1"
        _venv_create_at "$VENV_HOME/$1" || return 1
        _venv_source_activate "$VENV_HOME/$1"
    else
        if [ -z "${1-}" ]; then
            printf 'Making new default environment in current directory\n'
            if _venv_has_uv; then
                uv venv || return 1
            else
                _venv_create_at ".venv" || return 1
            fi
            if [ -d ".venv" ]; then
                _venv_source_activate ".venv"
            elif [ -d "venv" ]; then
                _venv_source_activate "venv"
            else
                printf 'Error: venv created but could not locate .venv/ or venv/\n' >&2
                return 1
            fi
        else
            printf "Making new environment '%s' in current directory\n" "$1"
            _venv_create_at "$1" || return 1
            _venv_source_activate "$1"
        fi
    fi
}

activate() {
    local env dir
    if [ -z "${1-}" ]; then
        for dir in .venv venv; do
            if [ -f "$dir/bin/activate" ]; then
                _venv_source_activate "$dir"
                return
            fi
        done
        printf 'Default local environment not found (looked for .venv/ and venv/).\n' >&2
        return 1
    fi

    if [ "$1" = "-g" ]; then
        shift
        if [ -z "${1-}" ]; then lsenv; return 0; fi
        env="$VENV_HOME/$1"
    else
        env="$1"
    fi

    if [ -d "$env" ]; then
        _venv_source_activate "$env"
    else
        printf "Error: environment '%s' not found.\n" "$env" >&2
        return 1
    fi
}

rmenv() {
    local global_env=false force=false opt target
    OPTIND=1
    while getopts ":gf" opt; do
        case "$opt" in
            g) global_env=true ;;
            f) force=true ;;
            *) printf 'Usage: rmenv [-g] [-f] <env_name_or_path>\n' >&2; return 1 ;;
        esac
    done
    shift $((OPTIND - 1))

    if [ -z "${1-}" ]; then
        printf 'Usage: rmenv [-g] [-f] <env_name_or_path>\n' >&2
        $global_env && lsenv
        return 1
    fi

    if $global_env; then
        target="$VENV_HOME/$1"
    else
        target="$1"
    fi

    [ -d "$target" ] || { printf 'Error: not a directory: %s\n' "$target" >&2; return 1; }

    [ -f "$target/pyvenv.cfg" ] || {
        printf "Refusing to remove '%s' (missing pyvenv.cfg; doesn't look like a venv).\n" "$target" >&2
        return 1
    }

    if ! $force; then
        printf "Remove virtual environment '%s'? [y/N] " "$target"
        read -r REPLY
        case "$REPLY" in
            [Yy]*) ;;
            *) printf 'Cancelled.\n'; return 1 ;;
        esac
    fi

    rm -rf -- "$target"
    printf 'Removed: %s\n' "$target"
}
