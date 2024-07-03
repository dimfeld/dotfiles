local spinner = require("lib.spinner")

-- Configuration options
local config = {
  holefill_cmd = "holefill.mjs",
  model = "anthropic/claude-3-5-sonnet-20240620",
}

local M = {}

-- Function to save visible lines
local function save_visible_lines(dest)
  local visible_lines = {}
  local lnum = 1
  local last_line = vim.fn.line("$")

  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local cursor_row = cursor_pos[1]
  local visible_cursor_row

  while lnum <= last_line do
    if vim.fn.foldclosed(lnum) == -1 then
      table.insert(visible_lines, vim.fn.getline(lnum))
      lnum = lnum + 1
    else
      table.insert(visible_lines, vim.fn.getline(vim.fn.foldclosed(lnum)))
      table.insert(visible_lines, "...")
      local end_line = vim.fn.foldclosedend(lnum)
      table.insert(visible_lines, vim.fn.getline(end_line))
      lnum = end_line + 1
    end

    if lnum == cursor_row then
      visible_cursor_row = #visible_lines
    end
  end

  local ok, err = pcall(vim.fn.writefile, visible_lines, dest)
  if not ok then
    error("Failed to write visible lines: " .. err)
  end

  return visible_cursor_row
end

M.setup = function(opts)
  config = vim.tbl_deep_extend("force", config, opts or {})
end

-- Main function to fill holes
M.fill_holes = function(opts)
  opts = opts or {}
  local model = opts.model or config.model

  local tmp_file
  local fill_tmp = vim.fn.tempname()

  local function cleanup(preserve)
    if tmp_file then
      os.remove(tmp_file)
    end
    os.remove(fill_tmp)
    spinner.stop(preserve)
  end

  local ok, err = pcall(function()
    local source_file
    if vim.fn.bufname("%") == "" then
      tmp_file = vim.fn.tempname()
      source_file = tmp_file
      vim.cmd("noa w " .. tmp_file)
    else
      if vim.bo.modified then
        vim.cmd("noa w")
      end
      source_file = vim.fn.expand("%:p")
    end

    local visible_cursor_row = save_visible_lines(fill_tmp)

    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    local cursor_line = cursor_pos[1] - 1
    local cursor_col = cursor_pos[2]

    spinner.start("Talking to LLM...")

    -- Run holefill and replace buffer with the result
    vim.system({
      config.holefill_cmd,
      "--file",
      source_file,
      "--mini",
      fill_tmp,
      "--model",
      model,
      "--mini-cursor",
      tostring(visible_cursor_row),
      "--cursor",
      tostring(cursor_line) .. ":" .. tostring(cursor_col),
    }, {
      text = true,
    }, function(result)
      local error = result.code ~= 0 or result.signal ~= 0
      cleanup(error)
      if error then
        print("Error executing holefill. Exit code: " .. result.code or result.signal)
        if result.stderr then
          print("Error output:")
          print(result.stderr)
        end
        return
      end

      vim.schedule(function()
        vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(result.stdout, "\n"))
        vim.bo.modified = true
      end)
    end)
  end)

  if not ok then
    cleanup(true)
    print("An error occurred: " .. tostring(err))
  end
end

return M
