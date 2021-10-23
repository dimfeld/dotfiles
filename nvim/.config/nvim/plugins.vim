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

" Command to yank to system clipboard
Plug 'ojroques/vim-oscyank'

" Extra commands for working with quickfix buffer entries.
Plug 'romainl/vim-qf'

" Close buffers without closing split
Plug 'qpkorr/vim-bufkill'

" Performance fix for things that use CursorHold
Plug 'antoinemadec/FixCursorHold.nvim'

" === Editing Plugins === "
" Trailing whitespace highlighting & automatic fixing
Plug 'ntpeters/vim-better-whitespace'

" Utilities for moving/renaming/deleting files
Plug 'tpope/vim-eunuch'

Plug 'tpope/vim-unimpaired'

" Improved motion in Vim
Plug 'ggandor/lightspeed.nvim'

" Autoadd closing parentheses, brackets, etc.
Plug 'windwp/nvim-autopairs'

" Telescope fuzzy finder
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'

" Treesitter for file syntax parsing used by other extensions
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

Plug 'prettier/vim-prettier', {
  \ 'do': 'yarn install',
  \ }

" Better terminal
Plug 'akinsho/toggleterm.nvim'

" === Git Plugins === "
" Enable git changes to be shown in sign column
" Plug 'mhinz/vim-signify'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'

" === Javascript Plugins === "
" Typescript syntax highlighting
Plug 'HerringtonDarkholme/yats.vim'

" ReactJS JSX syntax highlighting
Plug 'mxw/vim-jsx'

" Generate JSDoc commands based on function signature
Plug 'heavenshell/vim-jsdoc'

" Comment toggling
Plug 'JoosepAlviste/nvim-ts-context-commentstring'
Plug 'tpope/vim-commentary'

" === Syntax Highlighting === "
Plug 'gutenye/json5.vim'

" Hashicorp Tools
Plug 'hashivim/vim-hashicorp-tools'
Plug 'jvirtanen/vim-hcl'

" Markdown
Plug 'godlygeek/tabular'
Plug 'plasticboy/vim-markdown'
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }}

" Syntax highlighting for nginx
Plug 'chr4/nginx.vim'

" Syntax highlighting for javascript libraries
Plug 'othree/javascript-libraries-syntax.vim'

" Improved syntax highlighting and indentation
Plug 'othree/yajs.vim'

" Intellisense Engine
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'fannheyward/telescope-coc.nvim'
Plug 'dimfeld/coc-svelte', {'branch': 'updates', 'do': 'yarn install --frozen-lockfile && yarn build'}
Plug 'rodrigore/coc-tailwind-intellisense', {'do': 'npm install'}

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
Plug 'shadmansaleh/lualine.nvim'

" Debugging
Plug 'mfussenegger/nvim-dap'
Plug 'theHamsta/nvim-dap-virtual-text'
Plug 'rcarriga/nvim-dap-ui'
Plug 'nvim-telescope/telescope-dap.nvim'




" Initialize plugin system
call plug#end()
