-- Insert spaces when TAB is pressed.
vim.o.expandtab = true

-- Indentation amount for < and > commands.
vim.o.shiftwidth = 2
vim.o.softtabstop = 2
vim.o.tabstop = 4

local auGroup = vim.api.nvim_create_augroup('TabStops', {})

vim.api.nvim_create_autocmd('FileType', {
  group = auGroup,
  pattern = 'svelte',
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.formatoptions:append 'ro'
  end
})

vim.api.nvim_create_autocmd('FileType', {
  group = auGroup,
  pattern = 'rust',
  callback = function()
    vim.opt_local.shiftwidth = 4
  end
})

vim.api.nvim_create_autocmd('FileType', {
  group = auGroup,
  pattern = 'go',
  callback = function()
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
  end
})
