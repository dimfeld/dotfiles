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

function apply-pb-diff() {
  cdgr;
  pbpaste | git apply
}

alias cps="gh copilot suggest -t shell"

alias wind="/Users/dimfeld/.codeium/windsurf/bin/windsurf-next"

# AWS

alias aws-whoami='aws sts get-caller-identity'

alias rmp="~/Documents/projects/llmutils/dist/rmplan.js"
alias rmpd="~/Documents/projects/llmutils/src/rmplan/rmplan.ts"
alias rmpl="./src/rmplan/rmplan.ts"
# Not using prepare anymore since coding agents got better.
# function rmp-prep-and-run() {
#   rmp prepare --claude --next-ready "$@" && jj commit -m 'prepare plan' && rmp run --next-ready "$@"
# }
#
# function rmp-prep-and-run-codex() {
#   rmp prepare --claude --next-ready "$@" && jj commit -m 'prepare plan' && ALLOW_ALL_TOOLS=true rmp run -x codex-cli --next-ready "$@"
# }

function rmp-gen-and-run-codex() {
  rmp generate --claude --next-ready "$@" && jj commit -m 'generate plan' && ALLOW_ALL_TOOLS=true rmp run -x codex-cli --next-ready "$@"
}

function rmp-gen-and-run-claude() {
  rmp generate --claude --next-ready "$@" && jj commit -m 'generate plan' && rmp run "$@"
}


# Turbo
alias trl="turbo run --cache=local:rw"

# Temporarily unset claude alias so we can use the regular binary in the functions
unalias claude &> /dev/null

LLMUTILS_DIR=
if [ -d ~/Documents/projects/llmutils ]; then
  LLMUTILS_DIR=~/Documents/projects/llmutils
elif [ -d ~/projects/llmutils ]; then
  LLMUTILS_DIR=~/projects/llmutils
fi

alias baseclaude="ANTHROPIC_API_KEY= CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR=true CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY=1 claude --plugin-dir ${LLMUTILS_DIR}/claude-plugin"

function claudegr() {
  (
  cdgr
  baseclaude "$@"
  printf '\e[?1004l';
  )
}

function claudecwd() {
  baseclaude "$@"
  printf '\e[?1004l';
}

alias claude="claudegr"
alias claudes="claudegr --model sonnet"
alias claudeo="claudegr --model opus"

unalias codex &> /dev/null

function codexgr() {
  (
  cdgr
  AGENT=1 codex "$@"
  )
}

alias codex="codexgr"
alias codexhigh="codex -c model_reasoning_effort=high"
alias codexfa="codexgr --full-auto"
alias codexyolo="codexgr --dangerously-bypass-approvals-and-sandbox"

function rm-codex-plan() {
  codex -c model_reasoning_effort=high "$(rmp prompts generate-plan $@)"
}

function new-from-linear() {
  rmp import "$@" && \
    jj bookmark create "$1" -r@ && \
    jj bookmark track "$1" --remote origin && \
    jj commit -m 'import from linear'
}

# wezterm
if [ -n "$WEZTERM_PANE" ]; then
  alias rename-workspace="wezterm cli rename-workspace"
fi

# find and replace
function preplace() {
  rg "$1" -l | xargs sed -i '' "s|$1|$2|g"
}

# alias pnpm='sfw pnpm'

function backup-db() {
  pg-create-from-snapshot "$1_bak" "$1"
}

function restore-db() {
  pg-create-from-snapshot "$1" "$1_bak"
}

source ~/.zsh-functions/jj.zsh
source ~/.zsh-functions/_rmplan
alias rmws="rmplan_ws"

alias cl='chisel -p'
