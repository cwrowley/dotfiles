# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Installation

Install all dotfiles using GNU Stow:

```sh
./install.sh
```

This script:
1. Builds `emacs/.emacs.d/init.el` from the literate org-mode source (`emacs-init.org`) via `cd emacs/.emacs.d && make`
2. Creates `~/.zsh/completions/`
3. Runs `stow --dotfiles --ignore=NO --ignore=Makefile bash conda emacs git python shared tex tmux zsh`

To re-stow a single package after changes:

```sh
stow --dotfiles bash   # or zsh, git, emacs, etc.
```

## Repository Structure

Each top-level directory is a **Stow package** mapping to `$HOME`. Files named `dot-foo` are symlinked as `~/.foo` (Stow's `--dotfiles` convention). Files ending in `_NO` are disabled configs that Stow ignores.

```
bash/       → ~/.bashrc, ~/.bash_profile, etc.
conda/      → ~/.condarc
emacs/      → ~/.emacs.d/ (built from emacs-init.org)
git/        → ~/.gitconfig, ~/.gitignore_global
python/     → ~/.pyenv.sh, ~/.pythonstartup.py
shared/     → ~/.profile, ~/.aliases, ~/.functions, ~/.venv.sh
tex/        → ~/.latexmkrc
tmux/       → ~/.tmux.conf
zsh/        → ~/.zshrc, ~/.zprofile, ~/.zsh/
```

## Shell Configuration Architecture

Both bash and zsh follow a two-phase sourcing model:

- **Login shells** (`~/.bash_profile` / `~/.zprofile`) source `~/.profile` (`shared/dot-profile`), which sets PATH, environment variables, and tool-specific paths (Homebrew, Emacs, Python, TeX, PETSc, DaisyDSP, etc.)
- **Interactive shells** (`~/.bashrc` / `~/.zshrc`) source `~/.aliases`, `~/.functions`, and `~/.venv.sh` from `shared/`, then add shell-specific completions, prompt setup, and integrations

`shared/` contains files used verbatim by both shells. Shell-specific logic stays in `bash/` or `zsh/`.

## Emacs Configuration

The Emacs config uses **literate programming**: `emacs/.emacs.d/emacs-init.org` is the source of truth. `init.el` is generated and gitignored. After editing the org file, regenerate with:

```sh
cd emacs/.emacs.d && make
```

## Key Conventions

- **Disabling a config**: rename to add `_NO` suffix (e.g., `dot-inputrc_NO`); Stow will ignore it
- **Adding a new tool**: create a new top-level directory as a Stow package, add `dot-` prefixed files, and add the package name to `install.sh`
- The global gitignore (`git/dot-gitignore_global`) ignores `.DS_Store`, LaTeX artifacts, `__pycache__`, `.vscode`, `.claude`, `.cache`, and `TAGS`
