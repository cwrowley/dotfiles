# clean tex files
texclean() {
    emulate -L zsh
    setopt nullglob

    local -i dryrun=0
    [[ $1 == -n || $1 == --dry-run ]] && dryrun=1

    local texfiles=( *.tex(N) )
    (( ${#texfiles} )) || return 0

    local base=( ${texfiles%.tex} )
    local ext=( aux log out fdb_latexmk fls synctex.gz toc bbl blg )
    local junk=( ${^base}.${^ext}(N) )

    if (( dryrun )); then
        print -rl -- "${(@)junk}"
    else
        rm -f -- "${(@)junk}"
    fi
}
# Completion for texclean
_texclean() {
  _arguments \
    '(-n --dry-run)'{-n,--dry-run}'[print files that would be removed]'
}
compdef _texclean texclean

# load API keys
get_keys () {
    export GEMINI_API_KEY="$(security find-generic-password -a "clancyr@gmail.com" -s GEMINI_API_KEY -w)"
    export AI_SANDBOX_KEY="$(security find-generic-password -a "cwrowley@princeton.edu" -s AI_SANDBOX_KEY -w)"
}

# functions to sync files with math server
work_dir="Work/"
ref_dir="Reference/"
repo_dir="repos/"
rsync_local="$HOME/"
rsync_remote="math.princeton.edu:"
do_rsync () {
    rsync -rlptvuzhe ssh --exclude='.DS_Store' --exclude='__pycache__' --exclude="*venv" -- "$@"
}
rsync_pulldir () {
    syncdir=$1
    shift
    echo "Pulling directory $syncdir from $rsync_remote"
    do_rsync "$@" "${rsync_remote}${syncdir}" "${rsync_local}${syncdir}"
    print -P "%F{green}Finished pulling $syncdir $@ $(date)%f"
}
rsync_pushdir () {
    syncdir=$1
    shift
    echo "Pushing directory $syncdir to $rsync_remote"
    do_rsync "$@" "${rsync_local}${syncdir}" "${rsync_remote}${syncdir}"
    print -P "%F{green}Finished pushing $syncdir $@ $(date)%f"
}
pushwork () { rsync_pushdir $work_dir "$@"; }
pullwork () { rsync_pulldir $work_dir "$@"; }
pushref  () { rsync_pushdir $ref_dir "$@"; }
pullref  () { rsync_pulldir $ref_dir "$@"; }
pushrepos () { rsync_pushdir $repo_dir "$@"; }
pullrepos () { rsync_pulldir $repo_dir "$@"; }
# pushmath () { pushwork "$@"; pushref "$@"; }
# pullmath () { pullwork "$@"; pullref "$@"; }
pushmath () { pushrepos "$@"; }
pullmath () { pullrepos "$@"; }

# sync course files with H drive
push433 () {
    echo "Pushing directory mae433 to arizona"
    do_rsync "$@" $HOME/mae433/ arizona.princeton.edu:mae433/
}
pull433 () {
    echo "Pulling directory mae433 from arizona"
    do_rsync "$@" arizona.princeton.edu:mae433/ $HOME/mae433/
}

# Use emacs for info
info() {
    if [[ -n "$1" ]]; then
        emacsclient -e "(info \"$1\")" >/dev/null
    else
        emacsclient -e "(info)" >/dev/null
    fi
}
