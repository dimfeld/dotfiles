-- true for Codeium, false for Github Copilot
local codeium_enabled = false

vim.g.codeium_enabled = codeium_enabled

local disable_copilot_group = vim.api.nvim_create_augroup('DisableCopilot', {})
if codeium_enabled then
  vim.api.nvim_create_autocmd('BufEnter', {
    group = disable_copilot_group,
    pattern = '*',
    callback = function()
      vim.b.copilot_enabled = false
    end,
  })
end

vim.g.codeium_no_map_tab = true
vim.g.copilot_no_tab_map = true

local acceptCmd = codeium_enabled and 'codeium#Accept()' or 'copilot#Accept("")'

vim.keymap.set('i', '<C-J>', acceptCmd, {silent = true, expr = true})
vim.keymap.set('i', '<C-]>', acceptCmd, {silent = true, expr = true})

vim.g.copilot_filetypes = {
  markdown = true,
}
