scriptencoding utf-8

let g:BufKillCreateMappings = 0

source ~/.config/nvim/plugins.vim

let $NVIM_TUI_ENABLE_CURSOR_SHAPE = 1

" ============================================================================ "
" ===                           EDITING OPTIONS                            === "
" ============================================================================ "

set guifont=Inconsolata:h14
let g:neovide_remember_window_size=v:true
let g:neovide_cursor_animation_length=0.00
let g:neovide_cursor_trail_length=0.0

" Remap leader key to ,
let g:mapleader=','

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

" Setting for cursorhold workaround plugin
let g:cursorhold_updatetime = 100

set textwidth=120
set formatoptions-=t

" Scroll window without moving cursor
noremap z<Up> 10<c-e>
noremap z<Down> 10<c-y>

" Code Settings
"

set redrawtime=2000

"" Svelte
let g:svelte_preprocessor_tags = [
  \ { 'name': 'postcss', 'tag': 'style', 'as': 'scss' }
  \ ]
let g:svelte_preprocessors = ['typescript', 'postcss', 'scss']

augroup SvelteFiles
  au!
  au BufRead,BufNewFile *.svench setfiletype svelte
  au BufWritePre *.svench noautocmd call prettier#Autoformat()
  au FileType svelte setlocal formatoptions+=ro
augroup END

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
augroup RustFiles
  au!
  au FileType rust setlocal shiftwidth=4
augroup END

"" Go
augroup GoFiles
  au!
  au FileType go setlocal tabstop=4 shiftwidth=4
augroup END

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
"
inoremap <silent><expr> <TAB>
       \ pumvisible() ? "\<C-n>" :
       \ <SID>check_back_space() ? "\<TAB>" :
       \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

" Enter confirms completion if one has been selected.
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
inoremap <expr> <up> pumvisible() ? '<c-y><up>' : '<up>'
inoremap <expr> <down> pumvisible() ? '<c-y><down>' : '<down>'
inoremap <expr> <left> pumvisible() ? '<c-y><left>' : '<left>'
inoremap <expr> <right> pumvisible() ? '<c-y><right>' : '<right>'

" Close preview window when completion is done.
autocmd! CompleteDone * if pumvisible() == 0 && getcmdwintype () == '' | pclose | endif

 " Use K to show documentation in preview window.
nnoremap <silent> K <cmd>call <SID>toggle_documentation()<CR>
inoremap <silent> <c-k> <c-o><cmd>call <SID>toggle_documentation()<CR>

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

function! s:toggle_documentation()
  if (coc#float#has_float() > 0)
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
    call CocActionAsync('doHover')
    " call CocActionAsync('showSignatureHelp', function('<SID>hover_callback'))
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
command! -nargs=0 Format :call CocAction('format')

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR :call CocAction('runCommand', 'editor.action.organizeImport')

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

" === PostCss - SCSS syntax highlighting works here === "
augroup pcss
  au!
  au BufNewFile,BufRead *.pcss set syntax=scss
  au BufEnter *.pcss :syntax sync fromstart
augroup END

lua <<EOF

local npairs = require'nvim-autopairs'
local remap = vim.api.nvim_set_keymap

_G.MUtils= {}
MUtils.completion_confirm=function()
  if vim.fn.pumvisible() ~= 0  then
      return npairs.esc("<cr>")
  else
    return npairs.autopairs_cr()
  end
end

remap('i', '<CR>', 'v:lua.MUtils.completion_confirm()', {expr = true , noremap = true})

npairs.setup({
  check_ts = true,
  ignored_next_char = "[%w%.\"']", -- will ignore alphanumeric and `.` symbol
})

local Rule = require('nvim-autopairs.rule')
local cond = require('nvim-autopairs.conds')

require'nvim-treesitter.configs'.setup {
  ensure_installed = "maintained",
  context_commentstring = {
    enable = true
  },
  highlight = {
    enable = false,
    disable = { 'rust', 'javascript', 'javascript.jsx' }
  },
  indent = {
    enable = false
  },
  autopairs = { enable = true }
}

-- Status line configuration

local status_filename = {
  'filename',
  file_status=true,
  shorten=false,
  path=1 -- relative path
}

local status_diagnostics = {
  'diagnostics',
  sources={'coc'},
  sections={'error', 'warn'},
}

require('lualine').setup({
  options = {
    icons_enabled = true,
    theme = 'codedark',
    component_separators = {
      left = '',
      right = ''
    },
    section_separators = {
      left = '', 
      right = ''
    },
    disabled_filetypes = {}
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch'},
    lualine_c = {status_filename},
    lualine_x = {'filetype'},
    lualine_y = {status_diagnostics},
    lualine_z = {'progress', 'location'}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {status_filename},
    lualine_x = {'filetype'},
    lualine_y = {},
    lualine_z = {'location'}
  },
})


local toggleterm = require('toggleterm')
local toggleterm_open_mapping = [[<C-\>]]
toggleterm.setup{
  size = 80,
  open_mapping = toggleterm_open_mapping,
  hide_numbers = true,
  start_in_insert = true,
  insert_mappings = false,
  direction = 'vertical',
}

-- Tell neovim to catch these keystrokes instead of passing them through to the terminal.
function _G.set_terminal_keymaps()
  -- This key sequence exits from "terminal" mode into command mode.
  local term_escape = [[<C-\><C-n>]]
  local tmap = function(input, command)
    vim.api.nvim_buf_set_keymap(0, 't', input, term_escape .. command, { noremap = true })
  end

  tmap('<C-h>', '<C-w>h')
  tmap('<C-j>', '<C-w>j')
  tmap('<C-k>', '<C-w>k')
  tmap('<C-l>', '<C-w>l')

  vim.api.nvim_buf_set_keymap(0, 't', toggleterm_open_mapping, term_escape .. '<cmd>ToggleTerm<CR>', { noremap = true })
  vim.api.nvim_buf_set_keymap(0, 't', '<esc><esc>', term_escape, { noremap = true })
end

EOF

augroup TermKeys
  autocmd!
  autocmd TermOpen term://* lua set_terminal_keymaps()
augroup END


" Comments
vmap <silent> <leader>c gc
nmap <silent> <leader>c gcc

" ============================================================================ "
" ===                                UI                                    === "
" ============================================================================ "

" Enable true color support
set termguicolors

" Vim airline theme
let g:airline_theme='dark_minimal'

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
endfunction

command! ShowColors :call <SID>SynStack()<CR>
function! <SID>SynStack()
  if !exists("*synstack")
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc

set synmaxcol=3000
augroup Highlighting
  autocmd!
  autocmd BufEnter * syntax sync minlines=1000
augroup END

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
colorscheme OceanicNext

" ============================================================================ "
" ===                             KEY MAPPINGS                             === "
" ============================================================================ "

" === Telescope finder shortcuts ===
lua require('telescope').load_extension('coc')
lua require('telescope').load_extension('dap')
nnoremap <silent> ; :lua require('telescope.builtin').buffers()<cr>
nnoremap <silent> <leader>t :lua require('telescope.builtin').find_files()<cr>
nnoremap <silent> <leader>T :lua require('telescope.builtin').git_files()<cr>
nnoremap <silent> <leader>qf :lua require('telescope.builtin').quickfix()<cr>
nnoremap <silent> <leader>L :lua require('telescope.builtin').loclist()<cr>
nnoremap <silent> <leader>g :lua require('telescope.builtin').live_grep()<cr>
nnoremap <silent> <leader>G :call <SID>telescope_grep_on_git_repo()<cr>
nnoremap <silent> <leader>n :lua require('telescope.builtin').file_browser({ cwd=require('telescope.utils').buffer_dir() })<cr>
nnoremap <silent> <leader>N :lua require('telescope.builtin').file_browser()<cr>
nnoremap <silent> <leader>J :lua require('telescope.builtin').grep_string()<cr>
nnoremap <silent> <leader>v :lua require('telescope.builtin').treesitter()<cr>
nnoremap <silent> <leader>dl :Telescope coc document_diagnostics<cr>
nnoremap <silent> <leader>wl :Telescope coc workspace_diagnostics<cr>
nnoremap <silent> <leader>k :Telescope coc commands<cr>
nnoremap <silent> <leader>dr :Telescope coc references<cr>
nnoremap <silent> <leader>ds :Telescope coc document_symbols<cr>
nnoremap <silent> <leader>ws :Telescope coc workspace_symbols<cr>

function! s:telescope_grep_on_git_repo()
  execute "lua require('telescope.builtin').live_grep({search_dirs={'".trim(system("git rev-parse --show-toplevel"))."'}})"
endfunction

" Preload :e command with directory of current buffer.
nmap <leader>e :e %:h/

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
nmap <silent> [G <Plug>(coc-diagnostic-prev)
nmap <silent> ]G <Plug>(coc-diagnostic-next)
nmap <silent> [g <Plug>(coc-diagnostic-prev-error)
nmap <silent> ]g <Plug>(coc-diagnostic-next-error)

" === vim-better-whitespace === "
"   <leader>y - Automatically remove trailing whitespace
nmap <leader>y :StripWhitespace<CR>

" === Search shorcuts === "
"   <leader>/ - Clear highlighted search terms while preserving history
nmap <silent> <leader>/ <cmd>nohlsearch<CR>
"
" === Lightspeed Shortcuts
" Unmap s and S to get default behavior back.
try
  unmap s
  unmap S
catch
endtry

map <silent> f <Plug>Lightspeed_s<c-x>
map <silent> F <Plug>Lightspeed_S<c-x>

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
" Open 3-way diff
command! Gd :Gvdiffsplit!
" Use chunk from left side
nnoremap <expr> dgl &diff ? ':diffget //2<CR>' : ''
" Use chunk from right side
nnoremap <expr> dgr &diff ? ':diffget //3<CR>' : ''

" ============================================================================ "
" ===                                 MISC.                                === "
" ============================================================================ "

" === Search === "
set incsearch

" ignore case when searching, unless the search string has an upper case letter in it
set ignorecase
set smartcase

" Automatically re-read file if a change was detected outside of vim
set autoread

" Enable relative line numbers
set number
set relativenumber

" Enable spellcheck for markdown files
augroup markdown
  autocmd!
  autocmd BufRead,BufNewFile *.md setlocal spell
  autocmd BufRead,BufNewFile *.md setlocal formatoptions+=t
augroup END


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
" These map to cmd/option + arrow keys
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

" Quick run macro q
nnoremap <Tab> @q

command! EditInit e ~/.config/nvim/init.vim
command! ReloadInit source ~/.config/nvim/init.vim

" Prettier Settings
" Disable quickfix by default since it runs on every save
let g:prettier#quickfix_enabled = 0
let g:prettier#quickfix_auto_focus = 0
let g:prettier#autoformat_require_pragma = 0
let g:prettier#autoformat_config_present = 1

" If we do want to see the quickfix box, use this.
command! PO call PrettierWithOutput()

function! PrettierWithOutput()
  let old_quickfix = g:prettier#quickfix_enabled
  let g:prettier#quickfix_enabled = 1
  Prettier
  let g:prettier#quickfix_enabled = old_quickfix
endfunction

let g:ft = ''


" === Customize quickfix buffer ===
function! s:quickfix_settings()
  " o key opens the line under the quickfix and returns focus to quickfix
  nnoremap <silent> <buffer> o <CR><C-w>p
  " Open the selected line in the qucikfix buffer, and close the quickfix pane.
  nnoremap <silent> <buffer> O <CR>:cclose<CR>
endfunction
autocmd FileType qf call s:quickfix_settings()
