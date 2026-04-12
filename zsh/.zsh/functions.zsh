# Shared functions (get_keys, info, rsync helpers)
[ -r ~/.functions ] && source ~/.functions

# Remove LaTeX build artifacts in the current directory
# Usage: texclean [-n|--dry-run]
texclean() {
    emulate -L zsh
    setopt nullglob

    local -i dryrun=0
    [[ ${1-} == -n || ${1-} == --dry-run ]] && dryrun=1

    # Collect .tex basenames (without extension)
    local base=( *.tex(N:r) )
    (( ${#base} )) || return 0

    local ext=( aux log out fdb_latexmk fls synctex.gz toc bbl blg bcf run.xml )
    local junk=( ${^base}.${^ext}(N) )

    if (( dryrun )); then
        print -rl -- "${(@)junk}"
    else
        rm -f -- "${(@)junk}"
    fi
}
