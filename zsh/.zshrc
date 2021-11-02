#set -x
#zmodload zsh/zprof
export NVM_LAZY_LOAD=true
source ~/.zplug/init.zsh

# User configuration
#
# ## FZF FUNCTIONS ##

export FZF_COMPLETION_TRIGGER='`'
export FZF_DEFAULT_COMMAND='fd --type f'
export FZF_DEFAULT_OPTS="--bind 'ctrl-a:select-all'"

_fzf_compgen_path() {
  fd --hidden --follow --exclude ".git" . "$1"
}

_fzf_compgen_dir() {
  fd --type d --hidden --follow --exclude ".git" . "$1"
}

# fo [FUZZY PATTERN] - Open the selected file with the default editor
#   - Bypass fuzzy finder if there's only one match (--select-1)
#   - Exit if there's no match (--exit-0)
fo() {
  local files
  IFS=$'\n' files=($(fzf-tmux --query="$1" --multi --select-1 --exit-0 --preview 'bat --style=numbers --color=always --line-range :500 {}'))
  [[ -n "$files" ]] && ${EDITOR:-nvim} "${files[@]}"
}

# fr [FUZZY PATTERN] - Open the selected file with the default editor. Search the entire repository
#   - Bypass fuzzy finder if there's only one match (--select-1)
#   - Exit if there's no match (--exit-0)
fr() {
  local files
  IFS=$'\n' files=($(fd --type f --search-path $(git rev-parse --show-toplevel) | fzf-tmux --query="$1" --multi --select-1 --exit-0 --preview 'bat --style=numbers --color=always --line-range :500 {}'))
  [[ -n "$files" ]] && ${EDITOR:-nvim} "${files[@]}"
}

# fh [FUZZY PATTERN] - Search in command history
fh() {
  print -z $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed 's/ *[0-9]* *//')
}

# fbr [FUZZY PATTERN] - Checkout specified branch
# Include remote branches, sorted by most recent commit and limited to 30
fgb() {
  local branches branch query

  query="--query="
  if [[ -n "$1" ]]; then
    query="--query=$1"
  fi

  branches=$(git for-each-ref --count=30 --sort=-committerdate refs/heads/ --format="%(refname:short)") &&
  branch=$(echo "$branches" |
    fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m "$query" ) &&
  git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

# tm [SESSION_NAME | FUZZY PATTERN] - create new tmux session, or switch to existing one.
# Running `tm` will let you fuzzy-find a session mame
# Passing an argument to `ftm` will switch to that session if it exists or create it otherwise
ftm() {
  [[ -n "$TMUX" ]] && change="switch-client" || change="attach-session"
  if [ $1 ]; then
    tmux $change -t "$1" 2>/dev/null || (tmux new-session -d -s $1 && tmux $change -t "$1"); return
  fi
  session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf --exit-0) &&  tmux $change -t "$session" || echo "No sessions found."
}

# tm [SESSION_NAME | FUZZY PATTERN] - delete tmux session
# Running `tm` will let you fuzzy-find a session mame to delete
# Passing an argument to `ftm` will delete that session if it exists
ftmk() {
  if [ $1 ]; then
    tmux kill-session -t "$1"; return
  fi
  session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf --exit-0) &&  tmux kill-session -t "$session" || echo "No session found to delete."
}

# fuzzy grep via rg and open in vim with line number
fgr() {
  local file
  local line

  IFS=" " read -r file line <<<"$(rg --no-heading --line-number $@ | fzf -0 -1 | awk -F: '{print $1, $2}')"

  if [[ -n $file ]]
  then
     $EDITOR "$file" +$line
  fi
}

function delete-branches() {
  git branch |
    grep --invert-match '\*' |
    cut -c 3- |
    fzf --multi --preview="git log {}" |
    xargs --no-run-if-empty git branch --delete --force
}

export PATH="$HOME/google-cloud-sdk/bin:$HOME/bin/override:/usr/local/bin:/usr/local/sbin:/usr/local/share/python:$HOME/.cargo/bin:/usr/local/go/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/go/bin:/snap/bin:$HOME/bin/fzf/bin:$HOME/bin:$HOME/.local/bin"
if [[ -d "$GOPATH" ]]; then
  export PATH=$PATH:$GOPATH/bin
fi
# export MANPATH="/usr/local/man:$MANPATH"

fpath+=~/.zsh-functions

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

export ITERM_ENABLE_SHELL_INTEGRATION_WITH_TMUX=YES
[ -f ~/.iterm2_shell_integration.zsh ] && source ~/.iterm2_shell_integration.`basename $SHELL`

iterm2_print_user_vars() {
  it2git
}

SAVEHIST=10000
HISTSIZE=10000
HISTFILE=~/.zsh_history
setopt share_history

if (( $+commands[tag] )); then
  tag() { command tag "$@"; source ${TAG_ALIAS_FILE:-/tmp/tag_aliases} 2>/dev/null }
  alias ag=tag
fi

export EDITOR=nvim
export VISUAL=nvim

export BIND_IP=0.0.0.0

alias rg='rg -S'
alias gs='git status'
alias gd='git diff'
alias ig="sk -i --ansi -c 'rg --color=always --line-number "{}"'"
alias el="exa -l --git"
alias cat="bat"

# Must go before zsh-syntax-highlighting
autoload -U select-word-style && select-word-style bash

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#ff00ff,bg=cyan,bold,underline"
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=30
ZSH_AUTOSUGGEST_USE_ASYNC=1
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

zplug 'zplug/zplug', hook-build:'zplug --self-manage'
zplug "plugins/ssh-agent", from:oh-my-zsh
zplug "plugins/git", from:oh-my-zsh
zplug "zsh-users/zsh-syntax-highlighting", defer:2
# zplug "zsh-users/zsh-autosuggestions", defer:2

if ! zplug check; then
    zplug install
fi
zplug load

eval "$(zoxide init zsh)"
eval "$(starship init zsh)"

source ~/.aliases.zsh
source ~/.keybindings.zsh

[ -f ~/.zprofile ] && source ~/.zprofile
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Use this if it's defined in the local file
export DN_DISCORD_WEBHOOK=${DISCORD_WEBHOOK}

setopt auto_pushd

# Better autocompletion
autoload -Uz compinit && compinit
