source ~/.zsh/lib/venv.zsh

lsenv() {
  if [[ ! -d $VENV_HOME ]]; then
    print -r -- "No global env directory: $VENV_HOME"
    return 0
  fi

  _venv_globals_array
  print -r -- "Available environments in $VENV_HOME:"

  if (( ${#reply[@]} == 0 )); then
    print -r -- "(none)"
  else
    print -rl -- "${(o)reply[@]}" # (o) for sorted output
  fi
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
    local -a local_candidates=(.venv venv)

    # No args => try local defaults
    if [[ -z ${1-} ]]; then
        local dir
        for dir in "${local_candidates[@]}"; do
            if [[ -f "$dir/bin/activate" ]]; then
                _venv_source_activate "$dir"
                return
            fi
        done
        print -r -- "Default local environment not found (looked for .venv/ and venv/)."
        return 1
    fi

    # With args
    if [[ $1 == -g ]]; then
        shift
        if [[ -z ${1-} ]]; then
            lsenv
            return 0
        fi
        requested="$1"
        env="$VENV_HOME/$1"
    else
        requested=$1
        env=$1
    fi

    if [[ -d $env ]]; then
        _venv_source_activate "$env"
    else
        print -r -- "Error: environment '$requested' not found."
        return 1
    fi
}

rmenv() {
    emulate -L zsh
    
    local global_env=false force=false opt OPTIND
    while getopts ":gf" opt; do
        case "$opt" in
            g) global_env=true ;;
            f) force=true ;;
            *)
                print -r -- "Usage: rmenv [-g] [-f] <env_name_or_path>"
                return 1
                ;;
        esac
    done
    shift $((OPTIND - 1))

    if [[ -z ${1-} ]]; then
        print -r -- "Usage: rmenv [-g] [-f] <env_name_or_path>"
        $global_env && lsenv
        return 1
    fi

    local target
    if $global_env; then
        target="$VENV_HOME/$1"
    else
        target=$1
    fi

    if [[ ! -d $target ]]; then
        print -r -- "Error: not a directory: $target"
        return 1
    fi

    # Safety: require it to look like a venv (pyvenv.cfg is standard)
    if [[ ! -f $target/pyvenv.cfg ]]; then
        print -r -- "Refusing to remove '$target' (missing pyvenv.cfg; doesn't look like a venv)."
        return 1
    fi

    if ! $force; then
        # -q: yes/no; -r: raw
        if ! read -qr "REPLY?Remove virtual environment '$target'? [y/N] "; then
            print
            print -r -- "Cancelled."
            return 1
        fi
        print
    fi

    rm -rf -- "$target"
    print -r -- "Removed: $target"
}
