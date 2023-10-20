require('config.debugging')

local telescope = require('telescope');
local builtin = require('telescope.builtin')
local extensions = telescope.extensions

telescope.load_extension('coc');
telescope.load_extension('dap');
telescope.load_extension('file_browser');
telescope.load_extension('fzy_native');
telescope.load_extension('smart_open');

function getWorkspacePath()
  vim.wait(2000, function() return vim.g.coc_service_initialized == 1 end, 50)
  return vim.fn.CocAction('currentWorkspacePath')
end

vim.keymap.set('n', ';', function() builtin.buffers() end, {})
vim.keymap.set('n', '<space>', function() extensions.smart_open.smart_open({ filename_first=false }) end, {})
vim.keymap.set('n', '<leader>t', function() 
  builtin.find_files({ cwd=getWorkspacePath() })
end, {})
vim.keymap.set('n', '<leader>u', builtin.find_files, {})
vim.keymap.set('n', '<leader>t', builtin.git_files, {})
vim.keymap.set('n', '<leader>qf', builtin.quickfix, {})
vim.keymap.set('n', '<leader>qh', builtin.quickfixhistory, {})
vim.keymap.set('n', '<leader>L', builtin.loclist, {})
vim.keymap.set('n', '<leader>j', builtin.jumplist, {})
vim.keymap.set('n', '<leader>:', builtin.command_history, {})
vim.keymap.set('n', '<leader>g', function()
  builtin.live_grep({ cwd=getWorkspacePath() })
end, {})
vim.keymap.set('n', '<leader>h', builtin.search_history, {})
vim.keymap.set('n', '<leader>G', function()
  local toplevel = vim.fn.trim(vim.fn.system("git rev-parse --show-toplevel"))
  builtin.live_grep({ search_dirs={toplevel} })
end, {})
vim.keymap.set('n', '<leader>s', builtin.grep_string, {})
vim.keymap.set('n', '<leader>S', function()
  local toplevel = vim.fn.trim(vim.fn.system("git rev-parse --show-toplevel"))
  builtin.grep_string({ search_dirs={toplevel} })
end, {})
vim.keymap.set('n', '<leader>n', function()
  extensions.file_browser.file_browser({ cwd=require('telescope.utils').buffer_dir() })
end, {})
vim.keymap.set('n', '<leader>N', extensions.file_browser.file_browser, {})
vim.keymap.set('n', '<leader>v', builtin.treesitter, {})
vim.keymap.set('n', '<leader>l', builtin.resume, {})
vim.keymap.set('n', '<leader>dl', ':Telescope coc document_diagnostics<cr>', { silent = true })
vim.keymap.set('n', '<leader>wl', ':Telescope coc workspace_diagnostics<cr>', { silent = true })
vim.keymap.set('n', '<leader>dr', ':Telescope coc references<cr>', { silent = true })
vim.keymap.set('n', '<leader>ds', ':Telescope coc document_symbols<cr>', { silent = true })
vim.keymap.set('n', '<leader>ws', ':Telescope coc workspace_symbols<cr>', { silent = true })

vim.api.nvim_create_user_command('Debug', extensions.dap.commands, {})
