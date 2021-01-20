#!/bin/bash
set -x

mkdir -p ~/.tmux/plugins
if [[ ! -d ~/.tmux/plugins/tpm ]]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

cargo install bat bottom cargo-update exa fd-find git-delta ripgrep sd starship

