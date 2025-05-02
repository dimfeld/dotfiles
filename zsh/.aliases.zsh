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

alias jc='jj commit'
alias jjc='jj commit'
alias jjcm='jj commit -m'
alias jd='jj diff'
alias jjd='jj diff'
alias js='jj status'
alias jjs='jj status'
alias jjsh='jj show'
alias jje='jj edit'
alias jjpush='jj git push'
alias jjpb="jj log -r 'latest(heads(ancestors(@) & bookmarks()), 1)' --limit 1 --no-graph --ignore-working-copy -T bookmarks | tr -d '*'"

alias copydiff="jj diff --from main | pbcopy"

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
