local toggleterm = require('toggleterm')
local toggleterm_open_mapping = [[<C-\>]]
toggleterm.setup{
  size = 40,
  open_mapping = toggleterm_open_mapping,
  hide_numbers = true,
  start_in_insert = true,
  insert_mappings = false,
  direction = 'horizontal',
}

vim.api.nvim_create_user_command('VTerm', 'ToggleTerm size=80 direction=vertical', {})
vim.api.nvim_create_user_command('HTerm', 'ToggleTerm size=20 direction=horizontal', {})

-- Tell neovim to catch these keystrokes instead of passing them through to the terminal.
function set_terminal_keymaps()
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

local auGroup = vim.api.nvim_create_augroup('TerminalKeymaps', {})
vim.api.nvim_create_autocmd('TermOpen', {
  group = auGroup,
  pattern = 'term://*',
  callback = function()
    set_terminal_keymaps()
    vim.cmd.DisableWhitespace()
  end
})
