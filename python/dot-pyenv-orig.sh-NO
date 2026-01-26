export VENV_HOME="${VENV_HOME:-$HOME/.pyenv}"

# list environments
lsenv() {
    echo "Available environments in $VENV_HOME:"
    \ls -1 $VENV_HOME
}

# new environment
mkenv() {
    local global_env=false opt OPTARG OPTIND
    while getopts ":g" opt; do
        case $opt in
            g)
                global_env=true
                ;;
            *)
                echo "Usage: mkenv [-g <env_name>]"
                return 1
                ;;
        esac
    done
    shift $((OPTIND - 1))

    if $global_env; then
        echo "Making new global environment $1"
        pushd $VENV_HOME
        uv venv --no-project "$1"
        source "$1"/bin/activate
        popd
    else
        if [ -z "$1" ]; then
            echo "Making new default environment in current directory"
            uv venv
            source .venv/bin/activate
        else
            echo "Making new environment $1 in current directory"
            uv venv "$1"
            source "$1"/bin/activate
        fi
    fi
}

# activate an environment
activate() {
    local env
    if [ -z "$1" ]; then
        # no arguments: use default local directory
        for dir in .venv venv; do
            if [ -d "$dir" ]; then
                env=$dir
                break
            fi
        done
        if [ -z "$env" ]; then
            echo "Default local environment not found"
            return 1
        fi
    else
        # at least one argument
        if [ "$1" = "-g" ]; then
            # global environment
            shift
            if [ -z "$1" ]; then
                echo "Usage: activate [-g] <env_name>"
                lsenv
                return 1
            fi
            env=$VENV_HOME/"$1"
        else
            # local environment
            env="$1"
        fi
    fi
    if [ -d "$env" ]; then
        source "$env"/bin/activate
    else
        echo "Error: Environment '$1' not found."
        return 1
    fi
}
