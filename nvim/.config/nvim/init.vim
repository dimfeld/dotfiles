scriptencoding utf-8'

" Include core before plugins
lua require('config.core')

lua vim.g.skip_ts_context_commentstring_module = true

let g:BufKillCreateMappings = 0
source ~/.config/nvim/plugins.vim

let $NVIM_TUI_ENABLE_CURSOR_SHAPE = 1

" Enable matchit for better % behavior
runtime macros/matchit.vim

lua <<EOF

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

require('commands.dash')
require('commands.git')
require('commands.sourcegraph')

EOF

