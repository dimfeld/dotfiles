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

--- Get the comment string for the current filetype
--- @return string
local function get_comment_string()
  local commentstring = vim.filetype.get_option(vim.bo.filetype, "commentstring")
  if commentstring == "" then
    commentstring = "// %s"
  end
  -- Extract just the comment prefix (remove the %s placeholder and trim)
  local comment_prefix = commentstring:gsub("%%s", ""):gsub("%s+$", "")
  return comment_prefix
end

--- Get leading whitespace from a line
--- @param line_num number
--- @return string
local function get_leading_whitespace(line_num)
  local line = vim.fn.getline(line_num)
  local indent = line:match("^%s*")
  return indent or ""
end

--- Add AI comment markers above the current line or around a visual selection
--- @param opts table
local function add_ai_comment(opts)
  local comment = get_comment_string()
  local line1 = opts.line1
  local line2 = opts.line2
  local is_range = line1 ~= line2

  if is_range then
    -- Visual selection: add AI_COMMENT_START above and AI_COMMENT_END below
    local start_indent = get_leading_whitespace(line1)
    local end_indent = get_leading_whitespace(line2)

    local start_comment = start_indent .. comment .. " AI_COMMENT_START "
    local end_comment = end_indent .. comment .. " AI_COMMENT_END"

    -- Insert end comment first (so line numbers don't shift)
    vim.fn.append(line2, end_comment)
    -- Insert start comment above the selection
    vim.fn.append(line1 - 1, start_comment)

    -- Move cursor to end of the AI_COMMENT_START line
    vim.api.nvim_win_set_cursor(0, { line1, #start_comment + 1 })
    -- Enter insert mode at end of line
    vim.cmd("startinsert!")
  else
    -- Normal mode: add "AI: " above current line
    local indent = get_leading_whitespace(line1)
    local ai_comment = indent .. comment .. " AI: "
    vim.fn.append(line1 - 1, ai_comment)
    -- Move cursor to end of the AI: line
    vim.api.nvim_win_set_cursor(0, { line1, #ai_comment + 1 })
    -- Enter insert mode at end of line
    vim.cmd("startinsert!")
  end
end

-- Command for adding AI comment markers
vim.api.nvim_create_user_command("AIComment", add_ai_comment, {
  range = true,
  desc = "Add AI comment marker(s) - single line in normal mode, start/end markers in visual mode",
})

-- Keymap for normal mode
vim.keymap.set("n", "<leader>ar", "<cmd>AIComment<CR>", {
  desc = "Add AI comment marker above current line",
  silent = false,
})

-- Keymap for visual mode
vim.keymap.set("v", "<leader>ar", ":'<,'>AIComment<CR>", {
  desc = "Add AI comment markers around selection",
  silent = true,
})
