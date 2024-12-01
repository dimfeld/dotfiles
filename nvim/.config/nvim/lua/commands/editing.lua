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

-- Create a FindAndReplace command for project-wide search and replace
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
  desc = "Perform project-wide find and replace using /pattern/replacement/[flags] format",
})