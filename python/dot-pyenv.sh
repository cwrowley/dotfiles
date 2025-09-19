export VENV_HOME="${VENV_HOME:-$HOME/.pyenv}"

# list environments
lsenv() {
    echo "Available environments in $VENV_HOME:"
    \ls -1 $VENV_HOME
}

# new environment
mkenv() {
    local dir
    if [ "$1" = "-g" ]; then
        dir=$VENV_HOME
        shift
    else
        dir=.
    fi
    if [ -z "$1" ]; then
        echo "Usage: mkenv [-g] <env_name>"
        return 1
    fi
    echo "Making new environment $1 in $dir"
    pushd $dir
    python3 -m venv "$1"
    source "$1"/bin/activate
    pip install --upgrade pip
    pip install pip-tools
    popd
}

# activate an environment
activate() {
    local env
    if [ -z "$1" ]; then
        # no arguments: use default local directory
        for dir in .venv venv; do
            if [ -d $dir ]; then
                env=$dir
                break
            fi
        done
        if [ -z $env ]; then
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

