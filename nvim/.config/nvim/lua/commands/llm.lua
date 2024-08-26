local buffer_manager = require("lib.buffer_manager")
local spinner = require("lib.spinner")
local window = require("lib.window")

-- Configuration options
local config = {
  holefill_cmd = "holefill.mjs",
  model = "anthropic/claude-3-5-sonnet-20240620",
  autoattach = true,
}

local M = {}

M.setup = function(opts)
  config = vim.tbl_deep_extend("force", config, opts or {})

  M.context_buffers = buffer_manager.create_buffer_manager({
    autoattach = config.autoattach,
  })
end

M.set_default_model = function(model)
  config.model = model
end

-- fill a hole in a file
M.fill_holes = function(opts)
  opts = opts or {}
  local model = opts.model or config.model
  local cursor = opts.cursor

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

    cursor = cursor or window.get_cursor_range()

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

    local current_workspace = vim.fn.CocAction("currentWorkspacePath") or vim.fn.getcwd()
    for _, file in M.context_buffers.buffer_filenames() do
      -- Only include the file if the path is inside current_workspace
      if file ~= source_file and string.find(file, current_workspace) then
        table.insert(cmd, "--context")
        table.insert(cmd, file)
      end
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

M.ask_and_fill_holes = function(cursor)
  vim.ui.input({
    prompt = "What operation should be done?",
  }, function(operation)
    if not operation then
      return
    end

    require("commands.llm").fill_holes({
      operation = operation,
      cursor = cursor,
    })
  end)
end

M.prepare_context = function()
  -- Create a new buffer
  local new_buf = vim.api.nvim_create_buf(false, true)

  -- Table to store the lines we'll add to the new buffer
  local lines = {}

  local current_workspace = vim.fn.CocAction("currentWorkspacePath") or vim.fn.getcwd()

  -- Iterate through the provided buffer numbers
  for _, buf_num in ipairs(M.context_buffers.buffers) do
    -- Get the buffer name (filename)
    local buf_name = vim.api.nvim_buf_get_name(buf_num)

    local start = string.find(buf_name, current_workspace, 1, true)
    if start then
      buf_name = string.sub(buf_name, #current_workspace + 2)

      -- Add a header with the buffer name
      table.insert(lines, string.rep("-", 10))
      table.insert(lines, "File: " .. buf_name)
      table.insert(lines, string.rep("-", 10))
      table.insert(lines, "")

      -- Get the buffer contents
      local buf_lines = vim.api.nvim_buf_get_lines(buf_num, 0, -1, false)

      -- Add the buffer contents to our lines table
      for _, line in ipairs(buf_lines) do
        table.insert(lines, line)
      end

      table.insert(lines, "")
    end
  end

  -- Set the lines in the new buffer
  vim.api.nvim_buf_set_lines(new_buf, 0, -1, false, lines)

  -- Open the new buffer in a new window
  local content = table.concat(lines, "\n")
  vim.fn.setreg("+", content)
  vim.api.nvim_win_set_buf(0, new_buf)

  -- Return the new buffer number
  return new_buf
end

return M
