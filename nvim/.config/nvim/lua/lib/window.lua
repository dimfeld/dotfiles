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

--- @class CursorRange
--- @field visual boolean
--- @field start { line: number, col: number, pos: number[] }
--- @field stop { line: number, col: number, pos: number[] }

--- @return CursorRange
M.get_cursor_range = function()
  local start_pos = vim.fn.getpos("v")
  local end_pos = vim.fn.getpos(".")

  local mode = vim.fn.mode()
  local visual = mode == "v" or mode == "V" or mode == "<C-V>"

  -- In visual line mode, we don't care about which column the actual cursor is in
  if mode == "V" then
    start_pos[3] = 1
    end_pos[3] = vim.v.maxcol
  end

  return {
    visual = visual,
    start = {
      line = start_pos[2],
      col = start_pos[3],
      pos = start_pos,
    },
    stop = {
      line = end_pos[2],
      col = end_pos[3],
      pos = end_pos,
    },
  }
end

M.get_repo_buffer_path = function()
  local buf_path = vim.api.nvim_buf_get_name(0)
  if buf_path == "" then
    return
  end

  local git_root = require("lib.git").git_repo_toplevel()
  if git_root ~= "" and buf_path:find(git_root, 1, true) == 1 then
    -- Get relative path if buffer is inside git repo
    return buf_path:sub(#git_root + 2)
  else
    -- Use absolute path if not in a git repo
    return buf_path
  end
end

return M
