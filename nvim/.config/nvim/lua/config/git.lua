vim.api.nvim_create_user_command('Gd', ':Gvdiffsplit!', {})
vim.api.nvim_create_user_command('Gadd', ':Git add %', {})
-- Use chunk from left side
vim.keymap.set('n', 'dgl', "&diff ? ':diffget //2<CR>' : ''", { expr = true })
-- Use chunk from right side
vim.keymap.set('n', 'dgr', "&diff ? ':diffget //3<CR>' : ''", { expr = true })
