local M = {}

M.is_coc_diagnostic_window = function(win_id)
  -- Check if it's a floating window
  local config = vim.api.nvim_win_get_config(win_id)
  if config.relative == "" then
    return false
  end

  local buf = vim.api.nvim_win_get_buf(win_id)
  local hl = vim.inspect_pos(buf, 0, 0)
  if hl.syntax then
    for _, group in ipairs(hl.syntax) do
      if group.hl_group == "FgCocErrorFloatBgCocFloating" or group.hl_group == "FgCocWarningFloatBgCocFloating" then
        return true
      end
    end
  end

  -- If none of the above conditions are met, it's likely not a diagnostic window
  return false
end

return M
