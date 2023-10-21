scriptencoding utf-8'

let g:BufKillCreateMappings = 0

" Use Lua filetype detection
let g:do_filetype_lua=1
let g:did_load_filetypes=0

source ~/.config/nvim/plugins.vim

let $NVIM_TUI_ENABLE_CURSOR_SHAPE = 1

" Enable matchit for better % behavior
runtime macros/matchit.vim

lua <<EOF

require('config.core')
require('config.code_langs')
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

EOF

