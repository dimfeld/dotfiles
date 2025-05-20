export KEYTIMEOUT=1

function zle-line-init zle-keymap-select {
    VIM_PROMPT="%{$fg_bold[yellow]%} [% NORMAL]% %{$reset_color%}"
    RPS1="${${KEYMAP/vicmd/$VIM_PROMPT}/(main|viins)/} $EPS1"
    zle reset-prompt
}

zle
zle -N zle-line-init
zle -N zle-keymap-select
bindkey -e

bindkey "${key[Up]}" up-line-or-local-history
bindkey "${key[Down]}" down-line-or-local-history
bindkey "^[[A" up-line-or-local-history
bindkey "^[[B" down-line-or-local-history

up-line-or-local-history() {
    zle set-local-history 1
    zle up-line-or-history
    zle set-local-history 0
}
zle -N up-line-or-local-history
down-line-or-local-history() {
    zle set-local-history 1
    zle down-line-or-history
    zle set-local-history 0
}
zle -N down-line-or-local-history

# Reinstate some emacs shortcuts for convenience

bindkey '^P' up-history
bindkey '^N' down-history

# backspace and ^h working even after
# returning from command mode
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
bindkey "^[[3~" vi-delete-char

# ctrl-w removed word backwards
bindkey '^w' backward-kill-word
bindkey '^u' backward-kill-line
bindkey '^k' kill-line

# ctrl-r starts searching history backward
bindkey '^r' history-incremental-search-backward

bindkey '^[b' backward-word
bindkey '^[f' forward-word
bindkey '^[[1;3D' backward-word
bindkey '^[[1;3C' forward-word
bindkey '^[[1;9D' beginning-of-line
bindkey '^[[1;9C' end-of-line
bindkey '^A' beginning-of-line
bindkey "${key[Home]}" beginning-of-line
bindkey '^[[H' beginning-of-line
bindkey '^E' end-of-line
bindkey "${key[End]}" end-of-line
bindkey '^[[F' end-of-line

bindkey '^]' autosuggest-accept

# Disable clearing screen since I'm using this in tmux
bindkey -r "^L"
