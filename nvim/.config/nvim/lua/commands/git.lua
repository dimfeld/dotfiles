local cmdbar = require("config.snacks_commandbar")
local git = require("lib.git")

vim.api.nvim_create_user_command("Gd", ":Gvdiffsplit!", {})
vim.api.nvim_create_user_command("Gadd", ":Git add %", {})
-- Use chunk from left side
vim.keymap.set("n", "dgl", "&diff ? ':diffget //2<CR>' : ''", { expr = true, desc = "Get diff from left side" })
-- Use chunk from right side
vim.keymap.set("n", "dgr", "&diff ? ':diffget //3<CR>' : ''", { expr = true, desc = "Get diff from right side" })
-- vim.keymap.set("n", "dg", ":diffget", { expr = true, desc = "Get diff" })
vim.keymap.set("n", "dgo", ":diffget", { expr = true, desc = "Get diff" })

--- @param repo_path string
--- @param revision string
--- @param repo_root string
--- @param vcs "jj"|"git"
--- @param filetype string|nil
local function show_file_at_revision(repo_path, revision, repo_root, vcs, filetype)
  local current_filetype = filetype or vim.bo.filetype
  if current_filetype == "" then
    current_filetype = vim.filetype.match({ filename = repo_path }) or ""
  end

  local command
  if vcs == "jj" then
    command = { "jj", "file", "show", "-r", revision, repo_path }
  else
    command = { "git", "show", string.format("%s:%s", revision, repo_path) }
  end

  local result = vim
    .system(command, {
      cwd = repo_root,
      text = true,
    })
    :wait()

  if result.code ~= 0 then
    local error = vim.trim(result.stderr or "")
    if error == "" then
      error = string.format("Unable to load %s at %s", repo_path, revision)
    end
    vim.notify(error, vim.log.levels.ERROR)
    return
  end

  local lines = vim.split(result.stdout or "", "\n", { plain = true })
  if #lines > 0 and lines[#lines] == "" then
    table.remove(lines, #lines)
  end

  vim.cmd("tabnew")

  local target_buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_name(target_buf, string.format("%s@%s", repo_path, revision))
  vim.bo[target_buf].buftype = "nofile"
  vim.bo[target_buf].bufhidden = "wipe"
  vim.bo[target_buf].swapfile = false
  vim.bo[target_buf].modifiable = true
  vim.bo[target_buf].readonly = false
  vim.api.nvim_buf_set_lines(target_buf, 0, -1, false, lines)
  vim.bo[target_buf].modifiable = false
  vim.bo[target_buf].readonly = true
  vim.bo[target_buf].filetype = current_filetype
end

vim.api.nvim_create_user_command("FileRevision", function(opts)
  if #opts.fargs == 0 or #opts.fargs > 2 then
    vim.notify("Usage: FileRevision <revision> or FileRevision <repo-path> <revision>", vim.log.levels.ERROR)
    return
  end

  local repo_path
  local revision
  local repo_lookup_path = vim.api.nvim_buf_get_name(0)
  local repo
  local filetype

  if #opts.fargs == 1 then
    revision = opts.fargs[1]
    if repo_lookup_path == "" then
      vim.notify("Current buffer has no file path", vim.log.levels.ERROR)
      return
    end

    repo = git.repo_info(repo_lookup_path)
    if not repo.vcs then
      vim.notify("Current buffer is not inside a jj or git repository", vim.log.levels.ERROR)
      return
    end

    repo_path = git.repo_relative_path(repo_lookup_path)
    if not repo_path then
      vim.notify("Current file is not inside the repository root", vim.log.levels.ERROR)
      return
    end

    filetype = vim.bo.filetype
  else
    repo_path = opts.fargs[1]
    revision = opts.fargs[2]
    filetype = vim.filetype.match({ filename = repo_path }) or ""

    repo = git.repo_info(repo_lookup_path ~= "" and repo_lookup_path or nil)
    if not repo.vcs then
      vim.notify("Current directory is not inside a jj or git repository", vim.log.levels.ERROR)
      return
    end
  end

  show_file_at_revision(repo_path, revision, repo.root, repo.vcs, filetype)
end, {
  nargs = "+",
  desc = "Open the current file at a revision, or open <repo-path> at <revision>",
})

cmdbar.add_commands({
  {
    name = "Git permalink",
    category = "Git",
    action = function()
      require("gitlinker").get_buf_range_url("n", {

        action_callback = function(url)
          -- Strip off the #L\d+ part of the URL
          local new_url = vim.split(url, "#")[1]

          -- Replace with the saved cursor position from before opening the cmdbar
          new_url = new_url .. "#L" .. cmdbar.current_cursor.start.line
          if cmdbar.current_cursor.stop.line > cmdbar.current_cursor.start.line then
            new_url = new_url .. "-L" .. cmdbar.current_cursor.stop.line
          end

          require("gitlinker.actions").copy_to_clipboard(new_url)
        end,
      })
    end,
  },
  {
    name = "Git commit current file",
    category = "Git",
    action = function()
      vim.cmd("Git commit %")
    end,
  },
  {
    name = "Git Difftool",
    category = "Git",
    action = function()
      vim.cmd("Git difftool")
    end,
  },
  {
    name = "Git Blame",
    category = "Git",
    action = function()
      vim.cmd("Git blame")
    end,
  },
  {
    name = "Git 3-way Diff",
    category = "Git",
    action = function()
      vim.cmd("Gvdiffsplit!")
    end,
  },
})
