export KEYTIMEOUT=1

function zle-line-init zle-keymap-select {
    VIM_PROMPT="%{$fg_bold[yellow]%} [% NORMAL]% %{$reset_color%}"
    RPS1="${${KEYMAP/vicmd/$VIM_PROMPT}/(main|viins)/} $EPS1"
    zle reset-prompt
}

zle
zle -N zle-line-init
zle -N zle-keymap-select

# Use vim cli mode
bindkey -v

# Reinstate some emacs shortcuts for convenience

bindkey '^P' up-history
bindkey '^N' down-history

# backspace and ^h working even after
# returning from command mode
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char

# ctrl-w removed word backwards
bindkey '^w' backward-kill-word
bindkey '^u' backward-kill-line
bindkey '^k' kill-line

# ctrl-r starts searching history backward
bindkey '^r' history-incremental-search-backward

bindkey '^[b' backward-word
bindkey '^[f' forward-word
bindkey '^[[C' end-of-line
bindkey '^[[D' beginning-of-line

