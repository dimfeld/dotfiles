#!/bin/bash
set -x

echo "Installing zplug"
curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh

echo "Installing tmux plugin manager"
mkdir -p ~/.tmux/plugins
if [[ ! -d ~/.tmux/plugins/tpm ]]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

if [[ `which apt` ]]; then
  sudo apt install fzf
elif [[ `which brew` ]]; then
  brew install fzf
fi

if [[ `which cargo` ]]; then
  cargo install bat bottom cargo-update exa fd-find git-delta ripgrep sd starship
elif [[ `which brew ` ]]; then
  brew install bat bottom exa fd git-delta ripgrep sd starship
elif [[ `which apt ` ]]; then
  sudo apt install bat bottom exa fd git-delta ripgrep sd starship
fi

