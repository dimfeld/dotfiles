#!/bin/bash
set -x

mkdir -p ~/bin

echo "Installing zplug"
curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh

echo "Installing tmux plugin manager"
mkdir -p ~/.tmux/plugins
if [[ ! -d ~/.tmux/plugins/tpm ]]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

if [[ `which cargo` ]]; then
  # Prefer cargo for rust utils, if it's installed
  cargo install basic-http-server bat bottom cargo-update eza fd-find git-delta ripgrep sd starship zoxide

  if [[ `which brew` ]]; then
    brew install fzf nvim stow
  elif [[ `which apt` ]]; then
    sudo apt install nvim stow
    echo 'Installing fzf'
    ./install_fzf.sh
  fi
elif [[ `which brew ` ]]; then
  brew tap clementtsang/bottom
  brew install bat bottom eza fd git-delta ripgrep sd starship fzf stow nvim zoxide
elif [[ `which apt ` ]]; then
  echo 'Installing starship'
  curl -fsSL https://starship.rs/install.sh | bash
  echo 'Installing fzf'
  ./install_fzf.sh

  echo 'Installing eza sources'
  wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo tee /etc/apt/trusted.gpg.d/gierens.asc
  echo "deb http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
  sudo apt update

  sudo apt install bat eza fd-find git-delta ripgrep sd stow nvim zoxide
fi

python3 -m pip install --user --upgrade pynvim
nvim +PlugInstall +qall
nvim +UpdateRemotePlugins +qall
