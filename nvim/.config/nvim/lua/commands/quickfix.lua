local M = {}

--- @param line? number
M.remove_qf_item = function(line)
  local curqfidx = line or vim.fn.line(".")
  local qfall = vim.fn.getqflist()

  -- Return if there are no items to remove
  if #qfall == 0 then
    return
  end

  -- Remove the item from the quickfix list
  table.remove(qfall, curqfidx)
  vim.fn.setqflist(qfall, "r")

  -- Reopen quickfix window to refresh the list
  vim.cmd("copen")

  -- If not at the end of the list, stay at the same index, otherwise, go one up.
  local new_idx = curqfidx < #qfall and curqfidx or math.max(curqfidx - 1, 1)

  -- Set the cursor position directly in the quickfix window
  local winid = vim.fn.win_getid() -- Get the window ID of the quickfix window
  vim.api.nvim_win_set_cursor(winid, { new_idx, 0 })
end

M.qf_keymaps = function()
  vim.keymap.set("n", "dd", function()
    M.remove_qf_item()
  end, { buffer = true })
end

M.setup = function()
  local augroup = vim.api.nvim_create_augroup("QuickfixKeymap", {})
  vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    pattern = "qf",
    callback = M.qf_keymaps,
  })
end

return M
