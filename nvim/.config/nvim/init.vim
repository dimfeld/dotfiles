scriptencoding utf-8'

" Include core before plugins
lua require('config.core')

lua vim.g.skip_ts_context_commentstring_module = true

let g:BufKillCreateMappings = 0
source ~/.config/nvim/plugins.vim

" Enable matchit for better % behavior
runtime macros/matchit.vim

lua require('config')

