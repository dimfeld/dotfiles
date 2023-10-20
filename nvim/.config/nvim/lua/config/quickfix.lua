function keymaps()
  -- o key opens the line under the quickfix and returns focus to quickfix
  vim.api.nvim_buf_set_keymap(0, 'n', 'o', '<CR><C-w>p', {silent = true, noremap = true})
  -- Open the selected line in the qucikfix buffer, and close the quickfix pane.
  vim.api.nvim_buf_set_keymap(0, 'n', 'O', '<CR>:cclose<CR>', {silent = true, noremap = true})
end

local augroup = vim.api.nvim_create_augroup("QfKeymaps", {})

vim.api.nvim_create_autocmd('FileType', {
  group = augroup,
  pattern = "qf",
  callback = keymaps
})

