# My Dotfiles

Set up with zsh, tmux, and NeoVim. These started with the Jarvis configs and have
additional customizations from there.

# Installation

1. Set your shell to zsh and install oh-my-zsh
2. Clone this repository
3. install Stow (available with any package manager)
4. `cd dotfiles && ./install.sh && stow *`

Or if you only want to use certain parts of the config, substitute those directory names
instead of the `*` in the stow command.

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

The prefix key is bound to `option-a`. This is different from the 
common `ctrl-a` or default `ctrl-b`, but prevents conflicts with
`command-left` on a Mac, which sends `ctrl-a`.

- `Prefix ,` - Rename window
- `Prefix s` - Split horizontal
- `Prefix v` - Split vertical

## Command line Helpers

- `ftm <session name>` - Start or jump to this tmux session
- `ftm` - List active sessions
- `fo [words]` - Fuzzy search for files matching `words`. Open in editor.
- `fr [words]` - Like `fo`, but for the current git repository
- `fh [words]` - Search command history

# Neovim

Neovim is set up mostly for Rust and Svelte development right now.

- `Spacebar` - Page Down
- `-` - Page Up
- `Ctrl+h` - Switch window left
- `Ctrl+j` - Switch window down
- `Ctrl+k` - Switch window up
- `Ctrl+l` - Switch window right
- `:noa w` - Write file without formatting
- `,l` - Jump to line with easymotion
- `,w` - Jump to word with easymotion
- `,s<two characters>` - Jump to word starting with two characters
- `:Cdme` - Change directory to that of current file
- `:CdRepo` - Change directory to current git repository root

## Denite


### Open Denite

- `;` - Show buffer
- `,t` - Search filenames in current directory
- `,T` - Search filenames in current git repository
- `,g` - Search file contents in current directory
- `,j` - Search current directory for the word under the cursor

### Filter Mode

- `Ctrl+o` - Switch to normal mode
- `Esc` - Exit denite
- `Enter` - Open the file
- `Ctrl+t` - Open the file in a new tab
- `Ctrl+v` - Open the file in a vertical split
- `Ctrl+h` - Open the file in a horizontal split

### Normal Mode

- `Enter` - Open the file
- `q` or `Esc` - Close Denite
- `d` - Close the file
- `p` - Preview the file
- `Ctrl+o` or `i` - Switch to insert mode in filter prompt
- `Ctrl+t` - Open the file in a new tab
- `Ctrl+v` - Open the file in a vertical split
- `Ctrl+h` - Open the file in a horizontal split

## NERDTree

- `,n` - Toggle NERDTree
- `,f` - Open current file location in NERDTree

### Inside Window

- On a file
  - `o` - Open file an
  - `go` - Preview file
  - `i` - open in split
  - `s` - Open in vsplit
- On a directory
  - `o` - open or close directory
  - `O` - recursively open node
  - `x` - Close parent of node
  - `X` - Recursively close all node children
  - `e` - Explore this directory
- Tree Navigation
  - `P` - go to root
  - `p` - go to parent
  - `K` - first child
  - `J` - last child
  - `C` - Change tree root to selected directory
  - `u` - Move tree root up a directory
  - `U` - Move tree root up, keep old root open
  - `r` - refresh
  - `R` - refresh all
  - `cd` - Change CWD to selected directory
  - `CD` change tree root to CWD
  - `A` - Maximize or minimize NERDTree and window
  - `I` - toggle hidden files

## Intellisense (coc.nvim)

- `,dd` - Jump to symbol definition
- `,dr` - Jump to symbol references
- `,dj` - Jump to symbol implementation
- `,ds` - Search for symbols in project
- `]g` - Jump to next error and show popup
- `[g` - Jump to previous error and show popup
- `,dg` - Show popup about error on current line (if any)
- `K` - Open documentation for item under cursor
- `,rn` - Rename symbol
- `ctrl+space` or `tab` - Show completion popup

## Editing

- `,y` - Strip trailing whitespace
- `,h` - Open document-wide find and replace template
- `,/` - Clear highlighted search terms, but preserve history
- `,w` - Easymotion by word
- `,l` - Easymotion by line
- `,s` - Easymotion jump to 2-letter combo
- `:w!!` - Write file with sudo,
- `,p` - Delete visual selection without putting it in the buffer
- `]s` - Find next misspelled word, when spell check is on
- `[s` - Previous misspelled word
- `zg` - Add word to the spelling dictionary
- `zw` - Mark a word as misspelled
- `zug` and `zuw` - Undo the above
- `z=` - Suggest spellings
- `:spellr` - Repeat the spelling fix for all matches with the replaced word
- `:cdme` - cd to the directory of the current file

## Language Specific Commands

### Rust

- `:RustTest` - Run the test under the cursor

