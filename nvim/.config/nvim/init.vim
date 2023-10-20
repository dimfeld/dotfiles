scriptencoding utf-8'

let g:BufKillCreateMappings = 0

" Use Lua filetype detection
let g:do_filetype_lua=1
let g:did_load_filetypes=0

source ~/.config/nvim/plugins.vim

let $NVIM_TUI_ENABLE_CURSOR_SHAPE = 1

" ============================================================================ "
" ===                           EDITING OPTIONS                            === "
" ============================================================================ "

" Enable matchit for better % behavior
runtime macros/matchit.vim

" Remap leader key to ,
let g:mapleader=','


" Hides buffers instead of closing them
set hidden

" Scroll window without moving cursor
noremap z<Up> 10<c-e>
noremap z<Down> 10<c-y>

" Code Settings
"

"" Svelte
let g:svelte_preprocessor_tags = [
  \ { 'name': 'postcss', 'tag': 'style', 'as': 'scss' }
  \ ]
let g:svelte_preprocessors = ['typescript', 'postcss', 'scss']

" LUAREMOVE
" augroup SvelteFiles
"   au!
"   au FileType svelte setlocal formatoptions+=ro
"   au FileType svelte setlocal tabstop=2
"   " au FileType svelte let b:coc_additional_keywords = ["-"]
"   " au FileType svelte setlocal iskeyword=@,48-57,_,.,-,192-255
" augroup END

let g:vim_svelte_plugin_use_typescript = 1
let g:vim_svelte_plugin_use_sass = 1

" augroup ClosingTag
"   au!
"   " au FileType html iabbrev </ </<C-X><C-O>
"   " au FileType svelte iabbrev </ </<C-X><C-O>
" augroup END

" LUAREMOVE
" "" Rust
" augroup RustFiles
"   au!
"   au FileType rust setlocal shiftwidth=4
" augroup END

" "" Go
" augroup GoFiles
"   au!
"   au FileType go setlocal tabstop=4 shiftwidth=4
" augroup END


" ============================================================================ "
" ===                           PLUGIN SETUP                               === "
" ============================================================================ "

" let g:codeium_enabled = v:true

" augroup DisableCopilot
"   autocmd!
"   if (g:codeium_enabled)
"     autocmd BufEnter <silent><script><expr> let b:copilot_enabled=v:false
"   endif
" augroup END

" " Handling this manually so that copilot doesn't take precedence over the autocomplete.
" let g:codeium_no_map_tab = v:true
" let g:copilot_no_tab_map = v:true
" if (g:codeium_enabled)
"   imap <silent><script><expr> <C-J> codeium#Accept()
"   imap <silent><script><expr> <C-]> codeium#Accept()
" else
"   imap <silent><script><expr> <C-J> copilot#Accept("")
"   imap <silent><script><expr> <C-]> copilot#Accept("")
" endif

" let g:copilot_filetypes = {
"   \ 'markdown': v:true,
"   \ }


" Close preview window when completion is done.
autocmd! CompleteDone * if coc#pum#visible() == 0 && getcmdwintype () == '' | pclose | endif

 " Use K to show documentation in preview window.
nnoremap <silent> K <cmd>call <SID>toggle_documentation()<CR>
inoremap <silent> <c-k> <c-o><cmd>call <SID>toggle_signature_help()<CR>

function! s:toggle_documentation()
  if (coc#float#has_float() > 0)
    call coc#float#close_all()
  else
    call <SID>show_documentation()
  endif
endfunction

function! s:toggle_signature_help()
  if (coc#float#has_float() > 0)
    call coc#float#close_all()
  else
    call CocActionAsync('showSignatureHelp', function('<SID>hover_callback'))
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
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

vnoremap <silent> <leader>y <cmd>OSCYank<CR>

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('runCommand', 'editor.action.formatDocument')<CR>

augroup FormatOnSave
  au!
  au BufWritePost *.cjs FormatWrite
  au BufWritePost *.css FormatWrite
  au BufWritePost *.js FormatWrite
  au BufWritePost *.json FormatWrite
  au BufWritePost *.mjs FormatWrite
  au BufWritePost *.pcss FormatWrite
  au BufWritePost *.postcss FormatWrite
  au BufWritePost *.html FormatWrite
  au BufWritePost *.svelte FormatWrite
  au BufWritePost *.ts FormatWrite
  au BufWritePost *.py FormatWrite
augroup END

" === vim-javascript === "
" Enable syntax highlighting for JSDoc
let g:javascript_plugin_jsdoc = 1

" === vim-jsx === "
" Highlight jsx syntax even in non .jsx files
let g:jsx_ext_required = 0

" === PostCss - SCSS syntax highlighting works here === "
augroup pcss
  au!
  au BufNewFile,BufRead *.pcss set syntax=scss
  au BufEnter *.pcss :syntax sync fromstart
augroup END

lua <<EOF

require('config.core')
require('config.completion')
require('config.copilot')
require('config.debugging')
require('config.edit_commands')
require('config.formatters')
require('config.git')
require('config.lsp')
require('config.prose')
require('config.quickfix')
require('config.sourcegraph')
require('config.status_line')
require('config.tabstops')
require('config.telescope')
require('config.telescope_commandbar')
require('config.terminal')
require('config.theme')

require'nvim-treesitter.configs'.setup {
  ensure_installed = {
    'svelte', 'typescript'
  },
  context_commentstring = {
    enable = true,
    enable_autocmd = false,
    commentary_integration = {
      Commentary = false,
      CommentaryLine = false
    }
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

EOF

augroup TermKeys
  autocmd!
  autocmd TermOpen term://* lua set_terminal_keymaps()
  autocmd TermOpen term://* DisableWhitespace
augroup END

" ============================================================================ "
" ===                                UI                                    === "
" ============================================================================ "

" Set preview window to appear at bottom
set splitbelow

" ============================================================================ "
" ===                      CUSTOM COLORSCHEME CHANGES                      === "
" ============================================================================ "
"
command! ShowColors :call <SID>SynStack()<CR>
function! <SID>SynStack()
  if !exists("*synstack")
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc

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


" === Search shorcuts === "

" Repeat last command over visual selection
xnoremap <Leader>. q:<UP>I'<,'><Esc>$

" Allows you to save files you opened without write permissions via sudo
cmap w!! w !sudo tee %

" === vim-jsdoc shortcuts ==="
" Generate jsdoc for function under cursor
nmap <leader>z :JsDoc<CR>

" Change to the directory of the current file
command! Cdme cd %:p:h
" Change to the directory of the git repository
command! CdRepo execute "cd ".system("git rev-parse --show-toplevel")


let g:ft = ''

