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

" Close buffers without closing split
Plug 'qpkorr/vim-bufkill'

" === Editing Plugins === "
" Trailing whitespace highlighting & automatic fixing
Plug 'ntpeters/vim-better-whitespace'

" auto-close plugin
Plug 'rstacruz/vim-closer'

" Improved motion in Vim
Plug 'easymotion/vim-easymotion'

" Intellisense Engine
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Denite - Fuzzy finding, buffer management
Plug 'Shougo/denite.nvim'

" Snippet support
Plug 'Shougo/neosnippet'
Plug 'Shougo/neosnippet-snippets'

" Print function signatures in echo area
Plug 'Shougo/echodoc.vim'

Plug 'prettier/vim-prettier', { 'do': 'yarn install' }

" === Git Plugins === "
" Enable git changes to be shown in sign column
Plug 'mhinz/vim-signify'
Plug 'tpope/vim-fugitive'

" === Javascript Plugins === "
" Typescript syntax highlighting
Plug 'HerringtonDarkholme/yats.vim'

" ReactJS JSX syntax highlighting
Plug 'mxw/vim-jsx'

" Generate JSDoc commands based on function signature
Plug 'heavenshell/vim-jsdoc'

" Comment toggling
Plug 'preservim/nerdcommenter'

" Set filetype within a file based on the context
Plug 'Shougo/context_filetype.vim'

" === Syntax Highlighting === "

" Syntax highlighting for nginx
Plug 'chr4/nginx.vim'

" Syntax highlighting for javascript libraries
Plug 'othree/javascript-libraries-syntax.vim'

" Improved syntax highlighting and indentation
Plug 'othree/yajs.vim'

Plug 'evanleck/vim-svelte', {'branch': 'main'}
Plug 'cakebaker/scss-syntax.vim'
Plug 'rust-lang/rust.vim'
Plug 'cespare/vim-toml'
Plug 'dimfeld/coc-svelte', {'branch': 'master', 'do': 'yarn install --frozen-lockfile && yarn build'}
Plug 'mechatroner/rainbow_csv'


" === UI === "
" File explorer
" Disabled NERDTree in favor of vim-vinegar
" Seeing bugs in later versions, so pinned this for now
"Plug 'preservim/nerdtree', {'tag': '6.9.10'} |
"  Plug 'Xuyuanp/nerdtree-git-plugin' |
Plug 'ryanoasis/vim-devicons' |
" Plug 'tiagofumo/vim-nerdtree-syntax-highlight'

Plug 'tpope/vim-vinegar'

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }

" Colorscheme
Plug 'mhartington/oceanic-next'

" Customized vim status line
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Debugging
Plug 'puremourning/vimspector'


" Initialize plugin system
call plug#end()
