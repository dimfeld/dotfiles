# Setup fzf
# ---------
if [[ ! "$PATH" == */home/dimfeld/bin/fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}/home/dimfeld/bin/fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/home/dimfeld/bin/fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "/home/dimfeld/bin/fzf/shell/key-bindings.zsh"
