local spinner = require("lib.spinner")
local window = require("lib.window")

-- Configuration options
local config = {
  holefill_cmd = "holefill.mjs",
  model = "anthropic/claude-3-5-sonnet-20240620",
}

local M = {}

M.setup = function(opts)
  config = vim.tbl_deep_extend("force", config, opts or {})
end

M.set_default_model = function(model)
  config.model = model
end

-- fill a hole in a file
M.fill_holes = function(opts)
  opts = opts or {}
  local model = opts.model or config.model

  local tmp_file = nil
  local spinner_idx = nil

  local function cleanup(error)
    if tmp_file then
      os.remove(tmp_file)
    end
    spinner.stop(spinner_idx, error, vim.log.levels.ERROR)
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

    local cursor = window.get_cursor_range()
    local cursor_line = cursor.start.line - 1
    local cursor_col = cursor.start.col - 1

    spinner_idx = spinner.start("LLM", "Talking to model...")

    local cmd = {
      config.holefill_cmd,
      "--file",
      source_file,
      "--model",
      model,
      "--cursor",
      tostring(cursor.start.line - 1) .. ":" .. tostring(cursor.start.col - 1),
    }

    if opts.operation then
      table.insert(cmd, "--operation")
      table.insert(cmd, opts.operation)
    end

    if cursor.visual then
      table.insert(cmd, "--cursor-end")
      table.insert(cmd, tostring(cursor.stop.line - 1) .. ":" .. tostring(cursor.stop.col - 1))
    end

    -- Run holefill and replace buffer with the result
    vim.system(cmd, {
      text = true,
    }, function(result)
      local error = result.code ~= 0 or result.signal ~= 0
      if error then
        cleanup("Error executing holefill. Exit code: " .. result.code or result.signal)
        if result.stderr then
          print("Error output:")
          print(result.stderr)
        end
        return
      else
        cleanup()
      end

      vim.schedule(function()
        vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(result.stdout, "\n"))
        vim.bo.modified = true
      end)
    end)
  end)

  if not ok then
    cleanup()
    print("An error occurred: " .. tostring(err))
  end
end

return M
