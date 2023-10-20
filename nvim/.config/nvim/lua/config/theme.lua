vim.o.number = true
vim.o.termguicolors = true
-- Vertical split character is a space (hide it)
vim.o.fillchars = 'vert:.'
vim.g['airline_theme'] = 'dark_minimal'

-- Don't display mode in command line (lualine already shows it)
vim.o.showmode = false

-- Set floating window to be slightly transparent
vim.o.winblend = 10
-- Warp needs this instead
-- set winblend=0
