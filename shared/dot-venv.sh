# Python virtual environment tools: lsenv, mkenv, activate, rmenv
# POSIX-compatible; sourced by both ~/.bashrc and ~/.zshrc.

: "${VENV_HOME:=$HOME/.pyenv}"

_venv_has_uv() { command -v uv >/dev/null 2>&1; }

_venv_create_at() {
    if _venv_has_uv; then
        uv venv -- "$1"
    else
        local py
        if   command -v python3 >/dev/null 2>&1; then py=python3
        elif command -v python  >/dev/null 2>&1; then py=python
        else printf 'Error: no python or uv found in PATH\n' >&2; return 1
        fi
        "$py" -m venv -- "$1"
    fi
}

_venv_activate() {
    if [ -f "$1/bin/activate" ]; then
        . "$1/bin/activate"
    else
        printf 'Error: %s/bin/activate not found\n' "$1" >&2; return 1
    fi
}

lsenv() {
    [ -d "$VENV_HOME" ] || { printf 'No global env directory: %s\n' "$VENV_HOME"; return; }
    printf 'Available environments in %s:\n' "$VENV_HOME"
    local found=false d name
    for d in "$VENV_HOME"/*/; do
        [ -d "$d" ] || continue
        name="${d%/}"; name="${name##*/}"
        printf '  %s\n' "$name"
        found=true
    done
    $found || printf '  (none)\n'
}

mkenv() {
    local global=false opt
    OPTIND=1
    while getopts ":g" opt; do
        case $opt in
            g) global=true ;;
            *) printf 'Usage: mkenv [-g] [name]\n' >&2; return 1 ;;
        esac
    done
    shift $((OPTIND - 1))

    if $global; then
        [ -n "${1-}" ] || { printf 'Usage: mkenv -g <name>\n' >&2; lsenv; return 1; }
        mkdir -p -- "$VENV_HOME" && _venv_create_at "$VENV_HOME/$1" && _venv_activate "$VENV_HOME/$1"
    elif [ -z "${1-}" ]; then
        if _venv_has_uv; then uv venv; else _venv_create_at .venv; fi \
            && _venv_activate .venv
    else
        _venv_create_at "$1" && _venv_activate "$1"
    fi
}

activate() {
    local env
    if [ -z "${1-}" ]; then
        for env in .venv venv; do
            [ -f "$env/bin/activate" ] && _venv_activate "$env" && return
        done
        printf 'No local .venv/ or venv/ found.\n' >&2; return 1
    elif [ "$1" = -g ]; then
        [ -n "${2-}" ] || { lsenv; return 0; }
        _venv_activate "$VENV_HOME/$2"
    else
        _venv_activate "$1"
    fi
}

rmenv() {
    local global=false force=false opt target
    OPTIND=1
    while getopts ":gf" opt; do
        case $opt in
            g) global=true ;;
            f) force=true ;;
            *) printf 'Usage: rmenv [-g] [-f] <name>\n' >&2; return 1 ;;
        esac
    done
    shift $((OPTIND - 1))

    [ -n "${1-}" ] || { printf 'Usage: rmenv [-g] [-f] <name>\n' >&2; return 1; }
    if $global; then target="$VENV_HOME/$1"; else target="$1"; fi

    [ -d "$target" ]            || { printf 'Not a directory: %s\n'           "$target" >&2; return 1; }
    [ -f "$target/pyvenv.cfg" ] || { printf 'Not a venv (no pyvenv.cfg): %s\n' "$target" >&2; return 1; }

    if ! $force; then
        printf "Remove '%s'? [y/N] " "$target"
        read -r REPLY
        case $REPLY in [Yy]*) ;; *) printf 'Cancelled.\n'; return 1 ;; esac
    fi

    rm -rf -- "$target" && printf 'Removed: %s\n' "$target"
}
