#!/bin/bash
set -x

echo "Installing zplug"
curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh

echo "Installing tmux plugin manager"
mkdir -p ~/.tmux/plugins
if [[ ! -d ~/.tmux/plugins/tpm ]]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

if [[ `which cargo` ]]; then
  # Prefer cargo for rust utils, if it's installed
  cargo install bat bottom cargo-update exa fd-find git-delta ripgrep sd starship

  if [[ `which apt` ]]; then
    sudo apt install fzf stow
  elif [[ `which brew` ]]; then
    brew install fzf stow
  fi
elif [[ `which brew ` ]]; then
  brew tap clementtsang/bottom
  brew install bat bottom exa fd git-delta ripgrep sd starship fzf stow
elif [[ `which apt ` ]]; then
  echo 'Installing starship'
  curl -fsSL https://starship.rs/install.sh | bash
  sudo apt install bat exa fd-find git-delta ripgrep sd fzf stow
fi

