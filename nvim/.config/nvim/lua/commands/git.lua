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

--- @param revision string
local function show_file_at_revision(revision)
  local buf_path = vim.api.nvim_buf_get_name(0)
  if buf_path == "" then
    vim.notify("Current buffer has no file path", vim.log.levels.ERROR)
    return
  end

  local repo = git.repo_info(buf_path)
  if not repo.vcs then
    vim.notify("Current buffer is not inside a jj or git repository", vim.log.levels.ERROR)
    return
  end

  local repo_path = git.repo_relative_path(buf_path)
  if not repo_path then
    vim.notify("Current file is not inside the repository root", vim.log.levels.ERROR)
    return
  end

  local command
  if repo.vcs == "jj" then
    command = { "jj", "file", "show", "-r", revision, repo_path }
  else
    command = { "git", "show", string.format("%s:%s", revision, repo_path) }
  end

  local result = vim.system(command, {
    cwd = repo.root,
    text = true,
  }):wait()

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

  local current_filetype = vim.bo.filetype
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
  if opts.args == "" then
    vim.notify("Usage: FileRevision <revision>", vim.log.levels.ERROR)
    return
  end

  show_file_at_revision(vim.trim(opts.args))
end, {
  nargs = 1,
  desc = "Open the current file as it existed at a jj revset or git revision",
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
