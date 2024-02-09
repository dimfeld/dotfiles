" ============================================================================ "
" ===                               PLUGINS                                === "
" ============================================================================ "

" check whether vim-plug is installed and install it if necessary
let plugpath = expand('<sfile>:p:h'). '/autoload/plug.vim'
if !filereadable(plugpath)
    if executable('curl')
        let plugurl = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
        call system('curl -fLo ' . shellescape(plugpath) . ' --create-dirs ' . plugurl)
        if v:shell_error
            echom "Error downloading vim-plug. Please install it manually.\n"
            exit
        endif
    else
        echom "vim-plug not installed. Please install it manually or install curl.\n"
        exit
    endif
endif

call plug#begin('~/.config/nvim/plugged')

Plug 'dimfeld/section-wordcount.nvim'

" SQLite, used by various other plugins, including smart-open
Plug 'kkharji/sqlite.lua'

" Support library for plugins to enable repeating via .
Plug 'tpope/vim-repeat'

" Better increment/decrement
Plug 'monaqa/dial.nvim'

" Snippets
Plug 'L3MON4D3/LuaSnip', {'tag': 'v2.*', 'do': 'make install_jsregexp'}

" :AutoSaveToggle to automatically save files. Nice for markdown editing with
" live preview.
Plug '907th/vim-auto-save'

" Extra commands for working with quickfix buffer entries.
Plug 'romainl/vim-qf'

" Close buffers without closing split
Plug 'qpkorr/vim-bufkill'

" Performance fix for things that use CursorHold
Plug 'antoinemadec/FixCursorHold.nvim'

" When saving a file, create the directories if needed.
Plug 'jghauser/mkdir.nvim'

" === Editing Plugins === "
" Trailing whitespace highlighting & automatic fixing
Plug 'ntpeters/vim-better-whitespace'

" Utilities for moving/renaming/deleting files
" fork without <CR> remapping which interferes with autopairs
Plug 'dimfeld/vim-eunuch'

Plug 'tpope/vim-unimpaired'

" Better text replacement for replacing multiple similar words (different cases, etc)
Plug 'tpope/vim-abolish'

" Improved motion in Vim
Plug 'ggandor/leap.nvim'

" Autoadd closing parentheses, brackets, etc.
Plug 'windwp/nvim-autopairs'

" Show popup with key combo info
Plug 'folke/which-key.nvim'

" Telescope fuzzy finder
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-file-browser.nvim'
" Plug 'nvim-telescope/telescope-fzy-native.nvim'

Plug 'danielfalk/smart-open.nvim'

" Treesitter for file syntax parsing used by other extensions
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-treesitter/nvim-treesitter-textobjects'

" justfile highlighting
Plug 'NoahTheDuke/vim-just'

Plug 'mhartington/formatter.nvim'
Plug 'mattn/efm-langserver'

" Better terminal
Plug 'akinsho/toggleterm.nvim'

" === Git Plugins === "
" Enable git changes to be shown in sign column
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'

" === Javascript Plugins === "
" Typescript syntax highlighting
Plug 'HerringtonDarkholme/yats.vim'

" Generate JSDoc commands based on function signature
Plug 'heavenshell/vim-jsdoc'

" Comment toggling
Plug 'JoosepAlviste/nvim-ts-context-commentstring'
Plug 'tpope/vim-commentary'
Plug 'numToStr/Comment.nvim'

" === Syntax Highlighting === "
Plug 'gutenye/json5.vim'
Plug 'HiPhish/jinja.vim'

" Hashicorp Tools
Plug 'hashivim/vim-hashicorp-tools'
Plug 'jvirtanen/vim-hcl'

" Markdown
Plug 'godlygeek/tabular'
Plug 'plasticboy/vim-markdown'
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }}

Plug 'habamax/vim-asciidoctor'

" Syntax highlighting for nginx
Plug 'chr4/nginx.vim'

" Syntax highlighting for javascript libraries
Plug 'othree/javascript-libraries-syntax.vim'

" Improved syntax highlighting and indentation
Plug 'othree/yajs.vim'

" Intellisense Engine
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'fannheyward/telescope-coc.nvim'

Plug 'leafOfTree/vim-svelte-plugin'
Plug 'cakebaker/scss-syntax.vim'
Plug 'rust-lang/rust.vim'
Plug 'cespare/vim-toml'
Plug 'mechatroner/rainbow_csv'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }


" === UI === "
" File explorer
Plug 'tpope/vim-vinegar'
Plug 'kyazdani42/nvim-web-devicons'

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }

" Colorscheme
Plug 'dimfeld/oceanic-next'

" Customized vim status line
Plug 'nvim-lualine/lualine.nvim'

" Debugging
Plug 'mfussenegger/nvim-dap'
Plug 'theHamsta/nvim-dap-virtual-text'
Plug 'rcarriga/nvim-dap-ui'
Plug 'nvim-telescope/telescope-dap.nvim'


" === AI Stuff ===
" Plug 'sourcegraph/sg.nvim', { 'do': 'nvim -l build/init.lua' }
Plug 'dustinblackman/oatmeal.nvim'

" Plug 'github/copilot.vim'
Plug 'Exafunction/codeium.vim', { 'branch': 'main' }



" Initialize plugin system
call plug#end()
