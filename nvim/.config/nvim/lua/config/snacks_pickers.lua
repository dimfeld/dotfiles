local M = {}

local githelpers = require("lib.git")
local starts_with = require("lib.text").starts_with
local SnacksPicker = require("snacks.picker")

local root_files = {
  ".git",
  "pyproject.toml",
  "requirements.txt",
  "package.json",
}

local root_cache = {}
local use_git_ignore = true

local function buffer_dir()
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" then
    return vim.fn.getcwd()
  end
  return vim.fs.dirname(path)
end

--- @param path string
--- @return boolean
local function is_dotfiles_dir(path)
  return path:find(".config/nvim", 1, true) ~= nil or path:find("/dotfiles/", 1, true) ~= nil
end

--- @param path string
--- @return string
local function trim_colon_suffix(path)
  local colon_index = path:find(":")
  if colon_index then
    return path:sub(1, colon_index - 1)
  end
  return path
end

--- @param path string
--- @return string
local function relativize_to_git_root(path)
  local git_root = githelpers.git_repo_toplevel()
  if not git_root or git_root == "" then
    return path
  end

  if path:sub(1, #git_root) == git_root then
    local rel = path:sub(#git_root + 1)
    if rel:sub(1, 1) == "/" then
      rel = rel:sub(2)
    end
    return rel
  end

  return path
end

--- @param item snacks.picker.Item
--- @return string|nil
local function item_path(item)
  local path = item.file or item.path
  if not path and item.text and item.text:find("/", 1, true) then
    path = item.text
  end

  if not path then
    return nil
  end

  return relativize_to_git_root(trim_colon_suffix(path))
end

--- @param buffer_path string
--- @return string|nil
local function get_workspace_path(buffer_path)
  if root_cache[buffer_path] then
    return root_cache[buffer_path]
  end

  local result = vim.fs.find(root_files, {
    path = buffer_path,
    upward = true,
    limit = 1,
  })

  if result[1] then
    local dir = vim.fs.dirname(result[1])
    root_cache[buffer_path] = dir
    return dir
  end

  local dir = vim.lsp.buf.list_workspace_folders()[1]
  if dir then
    root_cache[buffer_path] = dir
    return dir
  end
end

--- @return string
local function choose_search_dir()
  local current_buffer_dir = buffer_dir()
  local workspace_dir = get_workspace_path(current_buffer_dir)

  if current_buffer_dir:find(".config/nvim", 1, true) then
    return vim.fn.expand("~/.config/nvim")
  end

  if workspace_dir and starts_with(current_buffer_dir, workspace_dir) then
    return workspace_dir
  end

  local cwd = vim.fn.getcwd()
  if starts_with(current_buffer_dir, cwd) then
    return cwd
  end

  local git_root = githelpers.git_repo_toplevel()
  if git_root ~= "" and starts_with(current_buffer_dir, git_root) then
    return git_root
  end

  return current_buffer_dir
end

--- @param dir string
--- @param opts? snacks.picker.Config
--- @return snacks.picker.Config
local function picker_dir_opts(dir, opts)
  local dotfiles_dir = is_dotfiles_dir(dir)
  return vim.tbl_deep_extend("force", {
    cwd = dir,
    hidden = dotfiles_dir,
    ignored = not use_git_ignore,
    exclude = dotfiles_dir and { ".git" } or nil,
  }, opts or {})
end

--- @param command string
local function open_command_line(command)
  vim.schedule(function()
    local keys = vim.api.nvim_replace_termcodes(":" .. command, true, false, true)
    vim.api.nvim_feedkeys(keys, "n", false)
  end)
end

--- @param opts? { filter_fn?: fun(cmd: string): boolean }
function M.command_history(opts)
  opts = opts or {}

  local history_string = vim.fn.execute("history cmd")
  local history_list = vim.split(history_string, "\n", { trimempty = true })
  local items = {}

  for i = #history_list, 3, -1 do
    local line = history_list[i]
    local _, finish = line:find("%d+ +")
    local cmd = finish and line:sub(finish + 1) or line

    if not opts.filter_fn or opts.filter_fn(cmd) then
      items[#items + 1] = {
        text = cmd,
      }
    end
  end

  SnacksPicker.pick({
    title = "Command History",
    items = items,
    format = "text",
    preview = "none",
    main = { current = true },
    layout = { preset = "vscode" },
    matcher = {
      fuzzy = false,
      ignorecase = true,
      smartcase = true,
      sort_empty = false,
    },
    sort = {
      fields = { "idx" },
    },
    confirm = function(picker, item)
      picker:close()
      if item then
        open_command_line(item.text)
      end
    end,
    actions = {
      edit_command_line = function(picker)
        local item = picker:current()
        picker:close()
        if item then
          open_command_line(item.text)
        end
      end,
    },
    win = {
      input = {
        keys = {
          ["<C-e>"] = { "edit_command_line", mode = { "i", "n" } },
        },
      },
      list = {
        keys = {
          ["<C-e>"] = { "edit_command_line", mode = { "n" } },
        },
      },
    },
  })
end

function M.quickfix_history()
  local current_nr = vim.fn.getqflist({ nr = 0 }).nr or 0
  local last_nr = vim.fn.getqflist({ nr = "$" }).nr or 0
  local items = {}

  for nr = last_nr, 1, -1 do
    local qf = vim.fn.getqflist({ nr = nr, title = 1, size = 1, idx = 1, id = 1 })
    if qf.id and qf.id ~= 0 then
      local current_marker = nr == current_nr and "* " or "  "
      local title = qf.title ~= "" and qf.title or "[Quickfix]"
      items[#items + 1] = {
        text = string.format("%s#%d [%d] %s", current_marker, nr, qf.size or 0, title),
        qf_nr = nr,
      }
    end
  end

  SnacksPicker.pick({
    title = "Quickfix History",
    items = items,
    format = "text",
    preview = "none",
    main = { current = true },
    layout = { preset = "vscode" },
    matcher = { sort_empty = false },
    sort = { fields = { "idx" } },
    confirm = function(picker, item)
      picker:close()
      if not item then
        return
      end

      local delta = item.qf_nr - current_nr
      if delta > 0 then
        vim.cmd("cnewer " .. delta)
      elseif delta < 0 then
        vim.cmd("colder " .. math.abs(delta))
      end

      vim.cmd("copen")
    end,
  })
end

--- @param picker snacks.Picker
function M.yank_selected_paths(picker)
  local selected = picker:selected({ fallback = true })
  local paths = {}

  for _, item in ipairs(selected) do
    local path = item_path(item)
    if path then
      paths[#paths + 1] = path
    end
  end

  if #paths == 0 then
    return
  end

  local result = table.concat(paths, "\n")
  local cb_opts = vim.opt.clipboard:get()

  if vim.tbl_contains(cb_opts, "unnamed") then
    vim.fn.setreg("*", result)
  end
  if vim.tbl_contains(cb_opts, "unnamedplus") then
    vim.fn.setreg("+", result)
  end
  vim.fn.setreg("", result)

  picker:close()
end

local function grep_in_dir(dir, opts)
  SnacksPicker.grep(picker_dir_opts(dir, opts))
end

local function files_in_dir(dir, opts)
  SnacksPicker.files(picker_dir_opts(dir, opts))
end

function M.setup()
  vim.api.nvim_create_user_command("BrowseGitIgnore", function()
    use_git_ignore = not use_git_ignore
    print("useGitIgnore: " .. tostring(use_git_ignore))
  end, {})

  vim.keymap.set("n", "\\", function()
    SnacksPicker.buffers()
  end, { desc = "List Buffers" })

  vim.keymap.set("n", "<space>", function()
    SnacksPicker.smart({
      formatters = {
        file = {
          filename_first = false,
        },
      },
    })
  end, { desc = "Smart Open" })

  vim.keymap.set("n", "<leader>t", function()
    files_in_dir(choose_search_dir())
  end, { desc = "Find files from Workspace Root" })

  vim.keymap.set("n", "<leader>N", function()
    files_in_dir(buffer_dir())
  end, { desc = "Find files from CWD" })

  vim.keymap.set("n", "<leader>T", function()
    local git_root = githelpers.git_repo_toplevel()
    files_in_dir(git_root ~= "" and git_root or choose_search_dir())
  end, { desc = "Find files from Git Root" })

  vim.keymap.set("n", "<leader>qf", function()
    SnacksPicker.qflist()
  end, { desc = "Search QuickFix Buffer" })

  vim.keymap.set("n", "<leader>qh", M.quickfix_history, { desc = "Search QuickFix History" })
  vim.keymap.set("n", "<leader>L", function()
    SnacksPicker.loclist()
  end, { desc = "Search Location List" })
  vim.keymap.set("n", "<leader>j", function()
    SnacksPicker.jumps()
  end, { desc = "Search Jump List" })

  vim.keymap.set("n", "<leader>g", function()
    grep_in_dir(choose_search_dir())
  end, { desc = "Grep in Workspace" })

  vim.keymap.set("n", "<leader>hs", function()
    SnacksPicker.search_history()
  end, { desc = "Search History" })

  vim.keymap.set("n", "<leader>G", function()
    local git_root = githelpers.git_repo_toplevel()
    grep_in_dir(git_root ~= "" and git_root or choose_search_dir())
  end, { desc = "Grep in Git Repo" })

  vim.keymap.set("n", "<leader>s", function()
    SnacksPicker.grep_word()
  end, { desc = "Grep for current string" })

  vim.keymap.set("n", "<leader>S", function()
    local git_root = githelpers.git_repo_toplevel()
    SnacksPicker.grep_word({
      cwd = git_root ~= "" and git_root or choose_search_dir(),
    })
  end, { desc = "Grep for current string in Git Repo" })

  vim.keymap.set("n", "<leader>n", function()
    SnacksPicker.explorer({
      cwd = buffer_dir(),
      ignored = not use_git_ignore,
    })
  end, { desc = "File Browser" })

  vim.keymap.set("n", "<leader>v", function()
    SnacksPicker.treesitter()
  end, { desc = "Show Treesitter Symbols" })

  vim.keymap.set("n", "<leader>R", function()
    SnacksPicker.resume()
  end, { desc = "Restore last Picker" })

  vim.keymap.set("n", "<leader>dd", function()
    SnacksPicker.lsp_definitions()
  end, { silent = true, desc = "Go to definition" })

  vim.keymap.set("n", "gd", function()
    SnacksPicker.lsp_definitions()
  end, { silent = true, desc = "Go to definition" })

  vim.keymap.set("n", "<leader>dl", function()
    SnacksPicker.diagnostics_buffer()
  end, { silent = true, desc = "Show Document Diagnostics" })

  vim.keymap.set("n", "<leader>wl", function()
    SnacksPicker.diagnostics()
  end, { silent = true, desc = "Show Workspace Diagnostics" })

  vim.keymap.set("n", "<leader>dr", function()
    SnacksPicker.lsp_references()
  end, { silent = true, desc = "Show References" })

  vim.keymap.set("n", "gr", function()
    SnacksPicker.lsp_references()
  end, { silent = true, desc = "Show References" })

  vim.keymap.set("n", "<leader>ds", function()
    SnacksPicker.lsp_symbols()
  end, { silent = true, desc = "Show Document Symbols" })

  vim.keymap.set("n", "<leader>ws", function()
    SnacksPicker.lsp_workspace_symbols()
  end, { silent = true, desc = "Show Workspace Symbols" })

  vim.keymap.set("n", "<leader>U", function()
    SnacksPicker.undo()
  end, { silent = true, desc = "Show Undo History" })

  vim.keymap.set("n", "<leader>:", function()
    M.command_history()
  end, { desc = "Search Command History" })

  vim.keymap.set("c", "<C-f>", function()
    local filter = nil
    local cmdline = vim.fn.getcmdline()

    if cmdline and cmdline ~= "" then
      local lowered = cmdline:lower()
      filter = function(text)
        return text:lower():find(lowered, 1, true) ~= nil
      end

      vim.fn.setcmdline("")
    end

    M.command_history({ filter_fn = filter })
  end, { desc = "Search Command History", silent = true })

  vim.keymap.set("n", "q:", function()
    M.command_history()
  end, { desc = "Search Command History" })
end

return M
