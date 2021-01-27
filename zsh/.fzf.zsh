# Setup fzf
# ---------
if [[ ! "$PATH" == *~/bin/fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}~/bin/fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source ~/bin/fzf/shell/completion.zsh 2> /dev/null

# Key bindings
# ------------
source ~/bin/fzf/shell/key-bindings.zsh
