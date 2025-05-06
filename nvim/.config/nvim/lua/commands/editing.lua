local win_util = require("lib.window")

--- @param fname string
--- @param args string
--- @param projectwide boolean
local function find_and_replace(fname, args, projectwide)
  -- Parse the arguments similar to substitute command
  local splits = vim.split(args, "/")
  if splits[1] == "" then
    table.remove(splits, 1)
  end

  local pattern, replacement = splits[1], splits[2]
  -- If no flags provided, default to empty string
  local flags = splits[3] or ""

  -- Validate the pattern and replacement
  if not pattern or not replacement then
    vim.notify("Invalid format. Use: " .. fname .. " /pattern/replacement/[flags]", vim.log.levels.ERROR)
    return
  end

  local root = projectwide and require("lib.git").git_repo_toplevel() or vim.fn.getcwd()

  -- Construct the substitute command
  local cmd = string.format(
    "args `rg -l %s %s` | argdo %%S/%s/%s/g%s | update",
    pattern,
    root,
    vim.fn.escape(pattern, "/"),
    vim.fn.escape(replacement, "/"),
    flags
  )

  -- Execute the command in a protected call
  local success, err = pcall(function()
    vim.cmd(cmd)
  end)

  if not success then
    vim.notify("Error during find and replace: " .. tostring(err), vim.log.levels.ERROR)
  else
    vim.notify("Find and replace completed successfully", vim.log.levels.INFO)
  end
end

-- FindAndReplace does a find and replace in all files under the current directory
vim.api.nvim_create_user_command("FindAndReplace", function(opts)
  -- Get the command arguments
  local args = opts.args

  -- Check if arguments are provided
  if args == "" then
    vim.notify("Usage: FindAndReplace /pattern/replacement/[flags]", vim.log.levels.ERROR)
    return
  end

  find_and_replace("FindAndReplace", args, false)
end, {
  nargs = 1,
  complete = function(_, line)
    -- No completion provided for now
    return {}
  end,
  desc = "Perform find and replace in the current directory using /pattern/replacement/[flags] format",
})

-- FindAndReplaceProject does a find and replace in all files under the git root
vim.api.nvim_create_user_command("FindAndReplaceProject", function(opts)
  -- Get the command arguments
  local args = opts.args

  -- Check if arguments are provided
  if args == "" then
    vim.notify("Usage: FindAndReplaceProject /pattern/replacement/[flags]", vim.log.levels.ERROR)
    return
  end

  find_and_replace("FindAndReplaceProject", args, true)
end, {
  nargs = 1,
  complete = function(_, line)
    -- No completion provided for now
    return {}
  end,
  desc = "Perform repository-wide find and replace using /pattern/replacement/[flags] format",
})

-- Copy the current buffer's path to the yank register
vim.api.nvim_create_user_command("CopyBufferPath", function()
  local buf_path = win_util.get_repo_buffer_path()
  if not buf_path then
    vim.notify("No file associated with current buffer", vim.log.levels.WARN)
    return
  end

  vim.fn.setreg('"', buf_path)
  vim.notify("Copied path: " .. buf_path, vim.log.levels.INFO)
end, {
  desc = "Copy the current buffer's path (relative to git root if possible) to the yank register",
})

vim.api.nvim_create_user_command("RmCopyBufferPath", function()
  local buf_path = win_util.get_repo_buffer_path()
  if not buf_path then
    vim.notify("No file associated with current buffer", vim.log.levels.WARN)
    return
  end

  if not vim.startswith(buf_path, "/") then
    buf_path = "repo:" .. buf_path
  end
  vim.fn.setreg('"', buf_path)
  vim.notify("Copied path: " .. buf_path, vim.log.levels.INFO)
end, {
  desc = "Copy the current buffer's path with repo: prefix to the yank register",
})
