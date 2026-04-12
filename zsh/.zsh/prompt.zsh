# Colors and prompt string expansion
autoload -U colors && colors
setopt prompt_subst

# left prompt
PROMPT='%B%F{cyan}%m%f%b %B%F{magenta}%1~%f%b %(?:%F{green}✓%f:%F{yellow}✗%f) '

# right prompt (git branch)
autoload -Uz vcs_info
zstyle ':vcs_info:git:*' formats ' (%b)'
zstyle ':vcs_info:*' enable git

precmd() { vcs_info }
RPROMPT='%F{green}${vcs_info_msg_0_}%f'
