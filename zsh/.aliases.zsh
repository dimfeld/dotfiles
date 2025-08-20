alias vi='nvim'
alias mv='mv -iv'
alias rm='rm -iv'
alias cp='cp -iv'
alias scp='scp -C'
alias ls='eza'
alias l='eza -l --git'
alias ad='pushd'
alias pd='popd'
alias cgr='cd $(gitroot)'

[ "$TERM" = "xterm-kitty" ] && alias ssh="kitty +kitten ssh"

if [[ `uname` == Darwin ]]; then
    alias top='top -o -cpu'
    alias l='eza -l --git'
else
   alias grep='grep --color=auto'
   alias fgrep='fgrep --color=auto'
   alias egrep='egrep --color=auto'
fi

if [[ -d ~/Documents/go ]]; then
   export GOPATH=~/Documents/go
elif [[ -d ~/go ]]; then
   export GOPATH=~/go
fi

export GIT_CEILING_DIRECTORIES=~
export VISUAL=nvim
export EDITOR=nvim
export PAGER=less

function fn() {
    find . -iname "*${*}*" | grep -v "~"
}

function mcd() {
    mkdir -pv ${1} && cd ${1}
}

export NVM_DIR=~/.nvm
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
alias pb='promptbox'

alias gp='git pull'
alias gcm='git commit -m'
alias gco-='git checkout -'
alias grc='git rebase --continue'

alias jjn='jj new'
function jjc() {
    for arg in "$@"; do
        if [ ! -e "$arg" ]; then
            echo "Error: Path '$arg' does not exist. Did you mean to use 'jjcm'?"
            return 1
        fi
    done
    jj commit "$@"
}
alias jjcm='jj commit -m'
alias jd='jj diff'
alias jjd='jj diff'
alias js='jj status'
alias jjsh='jj show'
alias jjpush='jj git push'
alias jjgp='jj git push'
alias jjgf='jj git fetch'
alias jjpb="jj log -r 'latest(heads(ancestors(@) & bookmarks()), 1)' --limit 1 --no-graph --ignore-working-copy -T local_bookmarks | tr -d '*'"

alias copydiff="jj diff --from main | pbcopy"

function jj-track-bookmark-and-new() {
  jj bookmark track $1@origin && jj new $1
}
alias jjbtn="jj-track-bookmark-and-new"
alias jjbt="jj bookmark track"

function jj-fetch-and-new() {
  BRANCH=${1:-$(jjpb)}
  jj git fetch && jj new $BRANCH
}
alias jjfn=jj-fetch-and-new

function jj-update-branch() {
  REV=${1:-@-}
  if [ $# -gt 0 ]; then
    shift
  fi
  jj bookmark move $(jjpb) --to "$REV" "$@"
}

alias jjub=jj-update-branch

function jjbm() {
  BOOKMARK=$1
  REV=${2:-@}
  shift 2

  jj bookmark move "$BOOKMARK" --to "$REV" "$@"
}

alias avpr='av pr create'
alias avb='av branch'
alias avbc='av commit -b'
alias avc='av commit'
alias avs='av stack'
alias avco='av switch'
alias avsw='av switch'
alias avsync='av sync --prune --rebase-to-trunk'
alias avpush='av sync'
alias avsub='av pr --all'

alias cps="gh copilot suggest -t shell"

alias wind="/Users/dimfeld/.codeium/windsurf/bin/windsurf-next"

# AWS

alias aws-whoami='aws sts get-caller-identity'

alias rmp="~/Documents/projects/llmutils/dist/rmplan.js"
alias rmpd="~/Documents/projects/llmutils/src/rmplan/rmplan.ts"
function rmp-prep-and-run() {
  rmp prepare --claude --next-ready "$@" && jj commit -m 'prepare plan' && rmp run --next-ready "$@" 
}

function rmp-yolo() {
  rmp generate --claude "$@" && jj commit -m 'generate plan' && rmp-prep-and-run "$@"
}

# Turbo
alias trl="turbo run --cache=local:rw"

# Temporarily unset claude alias so we can use the regular binary in the functions
unalias claude

function claudegr() {
  (
  cdgr
  ANTHROPIC_API_KEY= CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR=true claude "$@"
  )
}

function claudecwd() {
  ANTHROPIC_API_KEY= CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR=true claude "$@"
}

alias claude="claudegr"
alias claudes="claudegr --model sonnet"


# wezterm
if [ -n "$WEZTERM_PANE" ]; then
  alias rename-workspace="wezterm cli rename-workspace"
fi
