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

vnoremap <silent> <leader>y <cmd>OSCYank<CR>

" Add `:Format` command to format current buffer.
" command! -nargs=0 Format <cmd>lua vim.lsp.buf.formatting()

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR <cmd>lua vim.lsp.buf.execute_command({ command='editor.action.organizeImport' })

try

" Do not draw separators for empty sections (only for the active window) >
let g:airline_skip_empty_sections = 1

" Smartly uniquify buffers names with similar filename, suppressing common parts of paths.
let g:airline#extensions#tabline#formatter = 'unique_tail_improved'

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


" Editor theme
set background=dark


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
  " LSP colors
  hi LspDiagnosticsVirtualTextError guifg=#f04040
  hi LspDiagnosticsVirtualTextHint guifg=#aaaaaa
  hi LspDiagnosticsVirtualTextInformation guifg=#aaaaaa

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

" autocmd! ColorScheme * call TrailingSpaceHighlights()
autocmd ColorScheme OceanicNext call s:custom_jarvis_colors()

colorscheme OceanicNext

sign define LspDiagnosticsSignError text=• texthl=LspDiagnosticsSignError linehl= numhl=
sign define LspDiagnosticsSignWarning text=• texthl=LspDiagnosticsSignWarning linehl= numhl=
sign define LspDiagnosticsSignInformation text=• texthl=LspDiagnosticsSignInformation linehl= numhl=
sign define LspDiagnosticsSignHint text=• texthl=LspDiagnosticsSignHint linehl= numhl=


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
  ignored_next_char = "[%w%.]", -- will ignore alphanumeric and `.` symbol
})

local cmp = require'cmp'
local luasnip = require 'luasnip'

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

require'nvim-treesitter.configs'.setup {
  ensure_installed = "maintained",
  context_commentstring = {
    enable = true
  },
  highlight = {
    enable = false
  },
  autopairs = { enable = true }
}

local nvim_lsp = require'lspconfig'

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  -- Enable completion triggered by <c-x><c-o>
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap=true, silent=true }

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  -- buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', '<leader>dd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', '<leader>dj', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  -- buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  -- buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  -- buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  -- buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<leader>ac', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  -- buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '<leader>dg', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  buf_set_keymap('n', '[G', '<cmd>lua vim.lsp.diagnostic.goto_prev({ severity_limit="Error" })<CR>', opts)
  buf_set_keymap('n', ']G', '<cmd>lua vim.lsp.diagnostic.goto_next({ severity_limit="Error" })<CR>', opts)
  buf_set_keymap('n', '[g', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']g', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
  -- buf_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
  
end

vim.g.lsp_utils_codeaction_opts = {
  list = {
    border = true,
    title = 'Code Actions',
  }
}

vim.lsp.handlers['textDocument/codeAction'] = require'lsputil.codeAction'.code_action_handler

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

local simple_setups = { 'bashls', 'dockerls', 'gopls', 'html', 'pyright',
  'svelte', 'tailwindcss', 'tsserver', 'vimls', 'yamlls' }
for _, lsp in ipairs(simple_setups) do
  nvim_lsp[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
    flags = {
      debounce_text_changes = 150,
    }
  }
end

nvim_lsp.jsonls.setup{
  on_attach = on_attach,
  capabilities = capabilities,
  flags = {
    debounce_text_changes =150
  },
  commands = {
    Format = {
      function()
        vim.lsp.buf.range_formatting({},{0,0},{vim.fn.line("$"),0})
      end
    }
  }
}

require('rust-tools').setup({
  tools = { -- rust-tools options
      autoSetHints = true,
      hover_with_actions = true,
      inlay_hints = {
          parameter_hints_prefix = "",
          other_hints_prefix = "",
      },
  },
  server={
    on_attach=on_attach,
    capabilities = capabilities,
    flags = {
      debounce_text_changes =150
    },
  }
})

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
 vim.lsp.diagnostic.on_publish_diagnostics, {
   -- Enable underline, use default values
   underline = true,
   -- Enable virtual text only on Warning or above, override spacing to 2
   virtual_text = {
     prefix = "",
     spacing = 0,
   },
 }
)

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = {
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = function(fallback)
      if vim.fn.pumvisible() == 1 then
        vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<C-n>', true, true, true), 'n')
      elseif luasnip.expand_or_jumpable() then
        vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Plug>luasnip-expand-or-jump', true, true, true), '')
      else
        fallback()
      end
    end,
    ['<S-Tab>'] = function(fallback)
      if vim.fn.pumvisible() == 1 then
        vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<C-p>', true, true, true), 'n')
      elseif luasnip.jumpable(-1) then
        vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Plug>luasnip-jump-prev', true, true, true), '')
      else
        fallback()
      end
    end,
  },
  formatting = {
    format = function(entry, vim_item)
      -- fancy icons and a name of kind
      vim_item.kind = require("lspkind").presets.default[vim_item.kind]

      -- set a name for each source
      vim_item.menu = ({
        buffer = "[B]",
        nvim_lsp = "[L]",
        luasnip = "[S]",
      })[entry.source.name]
      return vim_item
    end,
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'buffer' },
    { name = 'path' }
  },
})
EOF

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
  autocmd BufEnter * syntax sync minlines=500
augroup END

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
" ============================================================================ "
" ===                             KEY MAPPINGS                             === "
" ============================================================================ "

" === Telescope finder shortcuts ===
" lua require('telescope').load_extension('coc')
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
nnoremap <silent> <leader>dr :lua require('telescope.builtin').lsp_references()<cr>
nnoremap <silent> <leader>dl :lua require('telescope.builtin').lsp_document_diagnostics()<cr>
nnoremap <silent> <leader>wl :lua require('telescope.builtin').lsp_workspace_diagnostics()<cr>
nnoremap <silent> <leader>ds :lua require('telescope.builtin').lsp_document_symbols()<cr>
nnoremap <silent> <leader>ws :lua require('telescope.builtin').lsp_workspace_symbols()<cr>
nnoremap <silent> <leader>k :lua require('telescope.builtin').commands()<cr>
" nnoremap <silent> <leader>k :Telescope coc commands<cr>

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
autocmd FileType qf call s:quickfix_settings()
function! s:quickfix_settings()
  " o key opens the line under the quickfix and returns focus to Quickfix
  nnoremap <silent> <buffer> o <CR><C-w>p
  nnoremap <silent> <buffer> O <CR>:cclose<CR>
endfunction
