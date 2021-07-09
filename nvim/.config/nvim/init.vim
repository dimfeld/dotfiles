scriptencoding utf-8

let g:BufKillCreateMappings = 0

source ~/.config/nvim/plugins.vim

let $NVIM_TUI_ENABLE_CURSOR_SHAPE = 1

" ============================================================================ "
" ===                           EDITING OPTIONS                            === "
" ============================================================================ "

" Remap leader key to ,
let g:mapleader=','

" Disable line numbers
set nonumber

" Don't show last command
set noshowcmd

" Yank and paste with the system clipboard
set clipboard=unnamed

" Hides buffers instead of closing them
set hidden

" === TAB/Space settings === "
" Insert spaces when TAB is pressed.
set expandtab

" Change number of spaces that a <Tab> counts for during editing ops
set softtabstop=2

" Indentation amount for < and > commands.
set shiftwidth=2

" do not wrap long lines by default
set nowrap

" Don't highlight current cursor line
set nocursorline

" Disable line/column number in status line
" Shows up in preview window when airline is disabled if not
set noruler

" Only one line for command line
set cmdheight=1

" Allow mouse clicking
set mouse=a

" Always show sign column so that it doesn't shift the buffer around when it
" shows up
set signcolumn=yes

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Code Settings
"

set redrawtime=2000

"" Svelte
let g:svelte_preprocessor_tags = [
  \ { 'name': 'postcss', 'tag': 'style', 'as': 'scss' }
  \ ]
let g:svelte_preprocessors = ['typescript', 'postcss', 'scss']
autocmd FileType svelte setlocal formatoptions+=ro

let g:vim_svelte_plugin_use_typescript = 1
let g:vim_svelte_plugin_use_sass = 1

" set local options based on subtype
function! OnChangeSvelteSubtype(subtype)
  " echom 'Subtype is '.a:subtype
  if empty(a:subtype) || a:subtype == 'html'
    setlocal commentstring=<!--%s-->
    setlocal comments=s:<!--,m:\ \ \ \ ,e:-->
    setlocal omnifunc=htmlcomplete#CompleteTags
  elseif a:subtype =~ 'css'
    setlocal comments=s1:/*,mb:*,ex:*/ commentstring&
    setlocal omnifunc=csscomplete#CompleteCSS
  else
    setlocal commentstring=//%s
    setlocal comments=sO:*\ -,mO:*\ \ ,exO:*/,s1:/*,mb:*,ex:*/,://
    setlocal omnifunc=javascriptcomplete#CompleteJS
  endif
endfunction

iabbrev </ </<C-X><C-O>

"" Rust
let g:rustfmt_autosave = 1
autocmd FileType rust setlocal shiftwidth=4

"" Go
autocmd FileType go setlocal tabstop=4 shiftwidth=4

" === Completion Settings === "

" Don't give completion messages like 'match 1 of 2'
" or 'The only match'
set shortmess+=c

" ============================================================================ "
" ===                           PLUGIN SETUP                               === "
" ============================================================================ "

" === Coc.nvim === "
let g:coc_global_extensions = [
      \'coc-css',
      \'coc-eslint',
      \'coc-git',
      \'coc-go',
      \'coc-highlight',
      \'coc-html',
      \'coc-json',
      \'coc-pyright',
      \'coc-rust-analyzer',
      \'coc-tsserver',
      \'coc-xml',
      \]

" use <tab> for trigger completion and navigate to next complete item
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~ '\s'
endfunction

inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

"Close preview window when completion is done.
autocmd! CompleteDone * if pumvisible() == 0 && getcmdwintype () == '' | pclose | endif

" Use K to show documentation in preview window.
nnoremap <silent> K <cmd>call <SID>toggle_documentation()<CR>
inoremap <silent> <c-k> <c-o><cmd>call <SID>toggle_documentation()<CR>

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

function! s:toggle_documentation()
  if (coc#float#has_float())
    call coc#float#close_all()
  else
    call <SID>show_documentation()
  endif
endfunction

function! s:hover_callback(e, r)
  if (a:r == v:false)
    call CocActionAsync('doHover')
  endif
endfunction

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('showSignatureHelp', function('<SID>hover_callback'))
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Use <leader>c to trigger code action in autocomplete popup, like autoimport.
inoremap <silent><expr> <leader>c
    \ pumvisible() ? "<c-g>u" : "<leader>c"
" When not in import mode, run code action on current line (usually auto-import)
nmap <leader>al <Plug>(coc-codeaction-line)
nmap <leader>ac <Plug>(coc-codeaction-cursor)

vnoremap <silent> <leader>y <cmd>OSCYank<CR>

" Add `:Format` command to format current buffer.
command! -nargs=0 Format <cmd>call CocAction('format')

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR :call CocAction('runCommand', 'editor.action.organizeImport')

try

" Do not draw separators for empty sections (only for the active window) >
let g:airline_skip_empty_sections = 1

" Smartly uniquify buffers names with similar filename, suppressing common parts of paths.
let g:airline#extensions#tabline#formatter = 'unique_tail'

" Custom setup that removes filetype/whitespace from default vim airline bar
let g:airline#extensions#default#layout = [['a', 'b', 'c'], ['x', 'z', 'warning', 'error']]

" Customize vim airline per filetype
" 'nerdtree'  - Hide nerdtree status line
" 'list'      - Only show file type plus current line number out of total
let g:airline_filetype_overrides = {
  \ 'nerdtree': [ get(g:, 'NERDTreeStatusline', ''), '' ],
  \ 'list': [ '%y', '%l/%L'],
  \ }

" Enable powerline fonts
let g:airline_powerline_fonts = 1

" Enable caching of syntax highlighting groups
let g:airline_highlighting_cache = 1

" Define custom airline symbols
if !exists('g:airline_symbols')
  let g:airline_symbols = {
    \ 'maxlinenr': ' ',
    \ }
endif

" Don't show git changes to current file in airline
let g:airline#extensions#hunks#enabled=0

catch
  echo 'Airline not installed. It should work after running :PlugInstall'
endtry

" Markdown
let g:vim_markdown_conceal = 0
let g:tex_conceal = ""
let g:vim_markdown_math = 1
let g:vim_markdown_frontmatter = 1
let g:vim_markdown_strikethrough = 1
let g:vim_markdown_no_extensions_in_markdown = 1
let g:vim_markdown_edit_url_in = 'vsplit'
let g:vim_markdown_folding_style_pythonic = 1
let g:vim_markdown_folding_level = 6

" === echodoc === "
" Enable echodoc on startup
let g:echodoc#enable_at_startup = 1

" === vim-javascript === "
" Enable syntax highlighting for JSDoc
let g:javascript_plugin_jsdoc = 1

" === vim-jsx === "
" Highlight jsx syntax even in non .jsx files
let g:jsx_ext_required = 0

" === javascript-libraries-syntax === "
let g:used_javascript_libs = 'underscore,requirejs,chai,jquery'

" === Signify === "
let g:signify_sign_delete = '-'

" === PostCss === "
augroup pcss
  au!
  au BufNewFile,BufRead *.pcss set syntax=scss
  au BufEnter *.pcss :syntax sync fromstart
augroup END

" ============================================================================ "
" ===                                UI                                    === "
" ============================================================================ "

" Enable true color support
set termguicolors

" Vim airline theme
let g:airline_theme='space'

" Change vertical split character to be a space (essentially hide it)
set fillchars+=vert:.

" Set preview window to appear at bottom
set splitbelow

" Don't dispay mode in command line (airilne already shows it)
set noshowmode

" Set floating window to be slightly transparent
set winbl=10

nmap <silent> <M-h> :bp<CR>
nmap <silent> <M-l> :bn<CR>
nmap <silent> <M-p> :b#<CR>
nmap <silent> <leader>p :b#<CR>

" ============================================================================ "
" ===                      CUSTOM COLORSCHEME CHANGES                      === "
" ============================================================================ "
"
" Add custom highlights in method that is executed every time a colorscheme is sourced
" See https://gist.github.com/romainl/379904f91fa40533175dfaec4c833f2f for details
" function! TrailingSpaceHighlights() abort
"   " Hightlight trailing whitespace
"   highlight Trail ctermfg=red guifg=red cterm=underline gui=underline
"   call matchadd('Trail', '\s\+\%#\@<!$', 100)
" endfunction

function! s:custom_jarvis_colors()
  " coc.nvim color changes
  hi link CocErrorSign WarningMsg
  hi link CocWarningSign Number
  hi link CocInfoSign Type

  " Make background transparent for many things
  hi Normal ctermbg=NONE guibg=NONE
  hi NonText ctermbg=NONE guibg=NONE
  hi LineNr ctermfg=NONE guibg=NONE
  hi SignColumn ctermfg=NONE guibg=NONE
  hi StatusLine guifg=#16252b guibg=#6699CC
  hi StatusLineNC guifg=#16252b guibg=#16252b

  " Try to hide vertical spit and end of buffer symbol
  hi VertSplit gui=NONE guifg=#17252c guibg=#17252c
  hi EndOfBuffer ctermbg=NONE ctermfg=NONE guibg=#17252c guifg=#17252c

  " Customize NERDTree directory
  hi NERDTreeCWD guifg=#99c794

  " Make background color transparent for git changes
  hi SignifySignAdd guibg=NONE
  hi SignifySignDelete guibg=NONE
  hi SignifySignChange guibg=NONE

  " Highlight git change signs
  hi SignifySignAdd guifg=#99c794
  hi SignifySignDelete guifg=#ec5f67
  hi SignifySignChange guifg=#c594c5

  hi DiffAdded guibg=#207020
  hi DiffRemoved guibg=#902020

  hi HopNextKey guifg=#00ff00
  hi HopNextKey1 guifg=#00ff00
  hi HopNextKey2 guifg=#00ff00
endfunction

command! ShowColors :call <SID>SynStack()<CR>
function! <SID>SynStack()
  if !exists("*synstack")
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc

" autocmd! ColorScheme * call TrailingSpaceHighlights()
autocmd! ColorScheme OceanicNext call s:custom_jarvis_colors()

" Call method on window enter
augroup WindowManagement
  autocmd!
  autocmd WinEnter * call Handle_Win_Enter()
augroup END

" Change highlight group of preview window when open
function! Handle_Win_Enter()
  if &previewwindow
    setlocal winhighlight=Normal:MarkdownError
  endif
endfunction

" Editor theme
set background=dark
try
  colorscheme OceanicNext
catch
  colorscheme slate
endtry
" ============================================================================ "
" ===                             KEY MAPPINGS                             === "
" ============================================================================ "

" === ferret search and replace ===
nmap <silent> <leader>G <Plug>(FerretAck)
nmap <silent> <leader>J <Plug>(FerretAckWord)

" === Telescope finder shortcuts ===
lua require('telescope').load_extension('coc')
nnoremap <silent> ; :lua require('telescope.builtin').buffers()<cr>
nnoremap <silent> <leader>t :lua require('telescope.builtin').find_files()<cr>
nnoremap <silent> <leader>T :lua require('telescope.builtin').git_files()<cr>
nnoremap <silent> <leader>qf :lua require('telescope.builtin').quickfix()<cr>
nnoremap <silent> <leader>L :lua require('telescope.builtin').loclist()<cr>
nnoremap <silent> <leader>g :lua require('telescope.builtin').live_grep()<cr>
nnoremap <silent> <leader>G :call <SID>telescope_grep_on_git_repo()<cr>
nnoremap <silent> <leader>n :lua require('telescope.builtin').file_browser()<cr>
nnoremap <silent> <leader>J :lua require('telescope.builtin').grep_string()<cr>
nnoremap <silent> <leader>v :lua require('telescope.builtin').treesitter()<cr>
nnoremap <silent> <leader>d :Telescope coc workspace_diagnostics<cr>
nnoremap <silent> <leader>k :Telescope coc commands<cr>
nnoremap <silent> <leader>dr :Telescope coc references<cr>
nnoremap <silent> <leader>ds :Telescope coc workspace_symbols<cr>

function! s:telescope_grep_on_git_repo()
  execute "lua require('telescope.builtin').live_grep({search_dirs={'".trim(system("git rev-parse --show-toplevel"))."'}})"
endfunction
" === Nerdtree shorcuts === "
"  <leader>n - Toggle NERDTree on/off
"  <leader>f - Opens current file location in NERDTree
" " NERDTree disabled
"nmap <leader>n :NERDTreeToggle<CR>
"nmap <leader>f :NERDTreeFind<CR>

" netrw file browser commands
" Open netrw on git repo
" nnoremap <silent> <leader>N :call <SID>netrw_on_git_repo()<CR>
" Open netrw on vim CWD
" nnoremap <silent> <leader>n :call <SID>netrw_on_cwd()<CR>
nnoremap <silent> <leader>E :e %:h<CR>

function! s:netrw_on_cwd()
  execute "e ".getcwd()
endfunction

function! s:netrw_on_git_repo()
  execute "e ".system("git rev-parse --show-toplevel")
endfunction

autocmd FileType netrw call s:netrw_keys()
function! s:netrw_keys()
  setlocal nohidden
  nmap <silent><buffer> <leader>n :BD<CR>
endfunction

map <leader>e :e %:h/

"   = - PageDown
"   -       - PageUp
noremap - <PageUp>
noremap = <PageDown>

" Quick window switching
nmap <C-h> <C-w>h
nmap <C-j> <C-w>j
nmap <C-k> <C-w>k
nmap <C-l> <C-w>l

" === coc.nvim === "
"   <leader>dd    - Jump to definition of current symbol
"   <leader>dr    - Jump to references of current symbol
"   <leader>dj    - Jump to implementation of current symbol
"   <leader>ds    - Fuzzy search current project symbols
nmap <silent> <leader>dd <Plug>(coc-definition)
" nmap <silent> <leader>dr <Plug>(coc-references)
nmap <silent> <leader>dj <Plug>(coc-implementation)
" nnoremap <silent> <leader>ds :<C-u>CocList -I -N --top symbols<CR>
nmap <silent> <leader>dg <Plug>(coc-diagnostic-info)
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)
nmap <silent> [G <Plug>(coc-diagnostic-prev-error)
nmap <silent> ]G <Plug>(coc-diagnostic-next-error)

" === vim-better-whitespace === "
"   <leader>y - Automatically remove trailing whitespace
nmap <leader>y :StripWhitespace<CR>

" === Search shorcuts === "
"   <leader>h - Find and replace
"   <leader>/ - Clear highlighted search terms while preserving history
map <leader>h :%s///<left><left>
nmap <silent> <leader>/ <cmd>nohlsearch<CR>

" === Hop Shortcuts ===
map <silent> <leader>w <cmd>HopWord<CR>
map <silent> <leader>l <cmd>HopLine<CR>
map <silent> <Space> <cmd>HopChar2<CR>



" === Easy-motion shortcuts ===" (disabled)
"   <leader>w - Easy-motion highlights first word letters bi-directionally
"map <leader>w <Plug>(easymotion-bd-w)
" Jump up and down by lines
"map <leader>l <Plug>(easymotion-bd-jk)
" Jump to a 2-character sequence.
"map <Space> <Plug>(easymotion-bd-f2)
" Smart case search, like that in native vim search
"let g:EasyMotion_smartcase = 1

" Replace built-in search with easymotion -- DISABLED
"map / <Plug>(easymotion-sn)
" omap / <Plug>(easymotion-sn)

" Allows you to save files you opened without write permissions via sudo
cmap w!! w !sudo tee %

" === vim-jsdoc shortcuts ==="
" Generate jsdoc for function under cursor
nmap <leader>z :JsDoc<CR>

" Delete current visual selection and dump in black hole buffer before pasting
" Used when you want to paste over something without it getting copied to
" Vim's default buffer
vnoremap <leader>p "_dP

" Delete current selection without yanking
vnoremap <leader>d "_d

" Change to the directory of the current file
command! Cdme cd %:p:h
" Change to the directory of the git repository
command! CdRepo execute "cd ".system("git rev-parse --show-toplevel")

" == Git keybindings
command! Gd :Gvdiffsplit!
nnoremap <expr> dgl &diff ? ':diffget //2<CR>' : ''
nnoremap <expr> dgr &diff ? ':diffget //3<CR>' : ''

" ============================================================================ "
" ===                                 MISC.                                === "
" ============================================================================ "

" Automaticaly close nvim if NERDTree is only thing left open
" NERDTree disabled
"autRocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" === Search === "
set incsearch

" ignore case when searching
set ignorecase

" if the search string has an upper case letter in it, the search will be case sensitive
set smartcase

" Automatically re-read file if a change was detected outside of vim
set autoread

" Enable line numbers
set number

" Enable spellcheck for markdown files
autocmd BufRead,BufNewFile *.md setlocal spell

" Set backups
if has('persistent_undo')
  set undofile
  set undolevels=3000
  set undoreload=10000
endif
set backupdir=~/tmp,.,~/
set directory=~/tmp,.,~/  " Where to keep swap files
set backup
set noswapfile

" Reload icons after init source
if exists('g:loaded_webdevicons')
  call webdevicons#refresh()
endif

" Quick move cursor from insert mode
imap <C-a> <C-o>^
imap <C-e> <C-o>$
map <C-a> ^
map <C-e> $
imap <M-b> <C-o>b
imap <M-f> <C-o>w
map <M-b> b
map <M-f> w

" When a visual range is selected, run a macro over each line in the range
xnoremap @ :<C-u>call ExecuteMacroOverVisualRange()<CR>
function! ExecuteMacroOverVisualRange()
  echo "@".getcmdline()
  execute ":'<,'>normal @".nr2char(getchar())
endfunction

nnoremap <Tab> @q

command! EditInit e ~/.config/nvim/init.vim
command! ReloadInit source ~/.config/nvim/init.vim

" Svelte filetype detection
if !exists('g:context_filetype#same_filetypes')
  let g:context_filetype#filetypes = {}
endif

" Defaults to 200 lines which is often not enough
let g:context_filetype#search_offset = 10000
let g:context_filetype#filetypes.svelte =
\ [
\   {'filetype' : 'javascript', 'start' : '<script>', 'end' : '</script>'},
\   {
\     'filetype': 'typescript',
\     'start': '<script\%( [^>]*\)\? \%(ts\|lang="\%(ts\|typescript\)"\)\%( [^>]*\)\?>',
\     'end': '</script>',
\   },
\   {'filetype' : 'css', 'start' : '<style \?.*>', 'end' : '</style>'},
\ ]

" Prettier Settings
" Disable quickfix by default since it runs on every save
let g:prettier#quickfix_enabled = 0
let g:prettier#quickfix_auto_focus = 0
let g:prettier#autoformat_require_pragma = 0
let g:prettier#autoformat_config_present = 1
au BufWritePre *.css,*.svelte,*.pcss,*.html,*.ts,*.js noautocmd | call prettier#Autoformat()

" If we do want to see the quickfix box, use this.
command! PO call PrettierWithOutput()

function! PrettierWithOutput()
  let old_quickfix = g:prettier#quickfix_enabled
  let g:prettier#quickfix_enabled = 1
  Prettier
  let g:prettier#quickfix_enabled = old_quickfix
endfunction

let g:ft = ''

" === NERDCommenter ===
let g:NERDDefaultAlign = 'left'
let g:NERDCompactSexyComs = 1
let g:NERDSpaceDelims = 1
let g:NERDCommentEmptyLines = 1
let g:NERDTrimTrailingWhitespace = 1
let g:NERDToggleCheckAllLines = 1
let g:NERDCustomDelimiters = {
  \ 'svelte': { 'left': '//', 'leftAlt': '/*', 'rightAlt': '*/' },
  \ 'html': { 'left': '<!--', 'right': '-->' },
  \}

" work with Svelte single-file components
fu! NERDCommenter_before()
  if (&ft == 'html') || (&ft == 'svelte')
    let g:ft = &ft
    let cfts = context_filetype#get_filetypes()
    if len(cfts) > 0
      if cfts[0] == 'svelte'
        let cft = 'html'
      elseif cfts[0] == 'scss'
        let cft = 'css'
      else
        let cft = cfts[0]
      endif
      exe 'setf ' . cft
    endif
  endif
endfu

fu! NERDCommenter_after()
  if (g:ft == 'html') || (g:ft == 'svelte')
    exec 'setf ' . g:ft
    let g:ft = ''
  endif
endfu


" === Customize quickfix buffer ===
autocmd FileType qf call s:quickfix_settings()
function! s:quickfix_settings()
  " o key opens the line under the quickfix and returns focus to Quickfix
  nnoremap <silent> <buffer> o <CR><C-w>p
  nnoremap <silent> <buffer> O <CR>:cclose<CR>
endfunction
