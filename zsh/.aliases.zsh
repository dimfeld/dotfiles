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
#source /usr/local/opt/nvm/nvm.sh
#export PYTHONPATH=/Library/Python/2.7/site-packages:$PYTHONPATH
alias py3env='source ~/py3env/bin/activate'
alias pb='promptbox'

alias gcm='git commit -m'
