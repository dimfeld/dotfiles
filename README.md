# My Dotfiles

Set up with zsh, tmux, fzf, and NeoVim.

# Installation

This might work. Realistically I'm probably making some assumptions about the
system that may not be true for your computer.

1. Set your shell to zsh and install oh-my-zsh
2. Clone this repository
3. `cd dotfiles && ./install.sh && ./stow.sh -R`

Or if you only want to use certain parts of the config, substitute those directory names
instead of using stow.sh.

This will create symlinks from the repository to the proper locations, ensuring that the
files are kept in sync with the repository.

zsh is configured to use the [Starship](https://starship.rs) prompt.

# Utility Replacements

- `exa` instead of `ls`
- `bat` instead of `cat`

# General Navigation

- `Option + Ctrl + hjkl` - Switch Tmux Pane
- `Option + Shift + hl` - Switch Tmux Window
- `Ctrl + hjkl` - Switch vi pane

# Tmux

The prefix key is bound to the default of `ctrl-b`.

- `Prefix ,` - Rename window
- `Prefix s` - Split horizontal
- `Prefix v` - Split vertical
- `Prefix z` - Maximize/restore tmux pane

## Command line Helpers

- `ftm <session name>` - Start or jump to this tmux session
- `ftm` - List active sessions
- `fo [words]` - Fuzzy search for files matching `words`. Open in editor.
- `fr [words]` - Like `fo`, but for the current git repository
- `fh [words]` - Search command history

