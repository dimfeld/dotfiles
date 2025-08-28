#set -x
# zmodload zsh/zprof
export NVM_LAZY_LOAD=true

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
    fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m "$query" --preview "git log {}" ) &&
  git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

# tm [SESSION_NAME | FUZZY PATTERN] - create new tmux session, or switch to existing one.
# Running `tm` will let you fuzzy-find a session mame
# Passing an argument to `ftm` will switch to that session if it exists or create it otherwise
ftm() {
  [[ -n "$TMUX" ]] && change="switch-client" || change="attach-session"
  if [ $1 ]; then
    (tmux $change -t "$1" 2>/dev/null) || (tmux new-session -d -s $1 && tmux $change -t "$1"); return
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

sw() {
  if [[ -n "$1" ]]; then
    SWITCH_WIN=$(kitten @ ls | jq ".[] | select(.wm_name == \"$1\") | .tabs | .[]| select(.is_active) | .windows |.[]| select(.is_active) | .id" | head -n1)
    if [[ -n "$SWITCH_WIN" ]]; then
      kitten @ focus-window -m "id:${SWITCH_WIN}"
      return
    fi
  fi

  SWITCH_TO=$(kitten @ ls | jq -r '.[] | .wm_name' | fzf --exit-0 --query "${1}")
  if [ -z "$SWITCH_TO" ]; then
    return
  fi

  # Get the ID of the window selected above
  SWITCH_WIN=$(kitten @ ls | jq ".[] | select(.wm_name == \"${SWITCH_TO}\") | .tabs | .[]| select(.is_active) | .windows |.[]| select(.is_active) | .id" | head -n1)

  kitten @ focus-window -m "id:${SWITCH_WIN}"
}
 
inover() {
  kitty @ launch --type=overlay "$1"
}

inpane() {
  kitty @ launch --location=neighbor "${@}"
}

# cd to git root
cdgr() {
  GITROOT=$(gitroot)
  if [[ $? -eq 0 ]]; then
    cd "$GITROOT"
  fi
}

function choose_aws_profile() {
    if ! command -v fzf &> /dev/null; then
        echo "fzf is not installed. Please install it or provide a profile name as an argument." >&2
        return 1
    fi

    local profiles=$(aws configure list-profiles)
    if [[ -z "$profiles" ]]; then
        echo "No AWS profiles found." >&2
        return 1
    fi

    local profile=$(echo "$profiles" | fzf --prompt="Select AWS profile: ")
    if [[ -z "$profile" ]]; then
        echo "No profile selected." >&2
        return 1
    fi

    echo "$profile"
}

function aws_login() {
    local profile

    if [[ $# -eq 1 ]]; then
        profile="$1"
    else
        profile=$(choose_aws_profile)
        if [[ $? -ne 0 ]]; then
            return 1
        fi
    fi

    echo "Logging in with profile: $profile"
    aws sso login --profile "$profile"
    export AWS_PROFILE="$profile"
    echo "AWS_PROFILE has been set to $profile"
}


function aws_set_profile() {
    local profile

    if [[ $# -eq 1 ]]; then
        profile="$1"
    else
        profile=$(choose_aws_profile)
        if [[ $? -ne 0 ]]; then
            return 1
        fi
    fi

    export AWS_PROFILE="$profile"
    echo "AWS_PROFILE has been set to $profile"
}

aws_assume_role() {
    local role_arn

    # Check if AWS CLI is configured
    if ! aws sts get-caller-identity &> /dev/null; then
        echo "AWS CLI is not configured. Please run 'aws configure' or log in first."
        return 1
    fi

    if [[ $# -eq 1 ]]; then
        role_arn="$1"
    else
        if ! command -v fzf &> /dev/null; then
            echo "fzf is not installed. Please install it or provide a role ARN as an argument."
            return 1
        fi

        # List available roles
        roles=$(aws iam list-roles --query 'Roles[].Arn' | jq -r '.[]')
        if [[ -z "$roles" ]]; then
            echo "No roles found for the current AWS profile."
            return 1
        fi

        role_arn=$(echo "$roles" | fzf --prompt="Select AWS role to assume: ")
        if [[ -z "$role_arn" ]]; then
            echo "No role selected."
            return 1
        fi
    fi

    echo "Assuming role: $role_arn"

    # Assume the selected role with credentials for 6 hours
    credentials=$(aws sts assume-role --role-arn "$role_arn" --role-session-name "AssumedRoleSession")

    if [[ $? -ne 0 ]]; then
        echo "Failed to assume role. Make sure you have permission to assume this role."
        return 1
    fi

    # Extract and export the temporary credentials
    export AWS_ACCESS_KEY_ID=$(echo "$credentials" | jq -r '.Credentials.AccessKeyId')
    export AWS_SECRET_ACCESS_KEY=$(echo "$credentials" | jq -r '.Credentials.SecretAccessKey')
    export AWS_SESSION_TOKEN=$(echo "$credentials" | jq -r '.Credentials.SessionToken')

    echo "Temporary credentials for the assumed role have been set as environment variables."
    echo "These credentials will expire in 1 hour by default."
}

aws_clear_tokens() {
    unset AWS_ACCESS_KEY_ID
    unset AWS_SECRET_ACCESS_KEY
    unset AWS_SESSION_TOKEN
}



# Activate a virtualenv if one is present
function activate_venv() {
    local current_dir="$PWD"
    local venv_dir=""

    while [[ "$current_dir" != "/" ]]; do
        if [[ -d "$current_dir/.venv" ]]; then
            venv_dir="$current_dir/.venv"
            break
        fi
        current_dir="$(dirname "$current_dir")"
    done

    if [[ -n "$venv_dir" ]]; then
        if [[ -f "$venv_dir/bin/activate" ]]; then
            echo "Activating virtual environment in $venv_dir"
            source "$venv_dir/bin/activate"
        else
            echo "Found .venv directory, but activate script is missing."
        fi
    else
        echo "No .venv directory found in current directory or its ancestors."
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
POSTGRES_APP_PATH="/Applications/Postgres.app/Contents/Versions/16/bin"
if [[ -d ${POSTGRES_APP_PATH} ]]; then
  export PATH=$PATH:${POSTGRES_APP_PATH}
fi
if [[ -d "$GOPATH" ]]; then
  export PATH=$PATH:$GOPATH/bin
fi
# export MANPATH="/usr/local/man:$MANPATH"

fpath+=~/.zsh-functions

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# if [[ $TERM_PROGRAM != "WarpTerminal" ]]; then
#   export ITERM_ENABLE_SHELL_INTEGRATION_WITH_TMUX=YES
#   [ -f ~/.iterm2_shell_integration.zsh ] && source ~/.iterm2_shell_integration.`basename $SHELL`
# fi

# iterm2_print_user_vars() {
#   it2git
# }

SAVEHIST=1000000
HISTSIZE=1000000
HISTFILE=~/.zsh_history
HIST_STAMPS="yyyy-mm-dd"
HISTORY_IGNORE="(cd|pwd|exit)*"
setopt EXTENDED_HISTORY      # Write the history file in the ':start:elapsed;command' format.
setopt INC_APPEND_HISTORY    # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY         # Share history between all sessions.
setopt HIST_IGNORE_DUPS      # Do not record an event that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS  # Delete an old recorded event if a new event is a duplicate.
setopt HIST_IGNORE_SPACE     # Do not record an event starting with a space.
setopt HIST_SAVE_NO_DUPS     # Do not write a duplicate event to the history file.
setopt HIST_VERIFY           # Do not execute immediately upon history expansion.
setopt APPEND_HISTORY        # append to history file (Default)
setopt HIST_NO_STORE         # Don't store history commands
setopt HIST_REDUCE_BLANKS    # Remove superfluous blanks from each command line being added to the history.

setopt +o nomatch

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
alias el="eza -l --git"
alias cat="bat"
alias j="just"

# Must go before zsh-syntax-highlighting
autoload -U select-word-style && select-word-style bash

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#eeaaaa,bg=black"
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=30
ZSH_AUTOSUGGEST_USE_ASYNC=1
ZSH_AUTOSUGGEST_STRATEGY=(history completion)


zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*:git-switch:*' sort false
# Enable completion list colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# preview directory's content with eza when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'

#
# Do preview in tmux popup when available
# zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
# Extra padding to make space for preview in tmux popup
# zstyle ':fzf-tab:complete:cd:*' popup-pad 30 0

source ~/.aliases.zsh
source ~/.keybindings.zsh

[ -f ~/.zprofile ] && source ~/.zprofile
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

eval "$(zoxide init zsh)"
eval "$(starship init zsh)"
# source <(av completion zsh)

# Use this if it's defined in the local file
export DN_DISCORD_WEBHOOK=${DISCORD_WEBHOOK}

export PRETTIERD_LOCAL_PRETTIER_ONLY=true

export TURBO_LOG_ORDER=grouped

setopt auto_pushd

# Better autocompletion
autoload -Uz compinit && compinit
source <(COMPLETE=zsh jj)

# zprof

### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

### End of Zinit's installer chunk

# zi snippet OMZP::git
zi snippet OMZP::ssh-agent
zi light Aloxaf/fzf-tab
zinit ice wait lucid atload'_zsh_autosuggest_start'
zinit light zsh-users/zsh-autosuggestions

# Added by Windsurf - Next
export PATH="/Users/dimfeld/.codeium/windsurf/bin:$PATH"
