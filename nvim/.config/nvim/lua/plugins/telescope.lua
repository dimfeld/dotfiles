-- A sorter that does case-insensitive substring matching, but doesn't reorder anything.
local preserve_order_sorter = function()
  local Sorter = require("telescope.sorters").Sorter

  return Sorter:new({
    discard = true,
    scoring_function = function(_, prompt, line, entry)
      if not line:lower():find(prompt:lower()) then
        return -1
      end

      -- Don't reorder anything
      return entry.index
    end,
  })
end

-- Copied from https://github.com/nvim-telescope/telescope.nvim/blob/10b8a82b042caf50b78e619d92caf0910211973d/lua/telescope/builtin/__internal.lua#L579
-- and modified to use `preserve_order_sorter` instead of the normal sorter.
local command_history = function(opts)
  local actions = require("telescope.actions")
  local finders = require("telescope.finders")
  local pickers = require("telescope.pickers")
  local utils = require("telescope.utils")

  local history_string = vim.fn.execute("history cmd")
  local history_list = utils.split_lines(history_string)

  local results = {}

  opts = opts or {}
  local filter_fn = opts.filter_fn

  for i = #history_list, 3, -1 do
    local item = history_list[i]
    local _, finish = string.find(item, "%d+ +")
    local cmd = string.sub(item, finish + 1)

    if filter_fn then
      if filter_fn(cmd) then
        table.insert(results, cmd)
      end
    else
      table.insert(results, cmd)
    end
  end

  pickers
    .new(opts, {
      prompt_title = "Command History",
      finder = finders.new_table(results),
      sorter = preserve_order_sorter(),

      attach_mappings = function(_, map)
        actions.select_default:replace(actions.set_command_line)
        map({ "i", "n" }, "<C-e>", actions.edit_command_line)
        return true
      end,
    })
    :find()
end

local root_files = {
  ".git",
  "pyproject.toml",
  "requirements.txt",
  "package.json",
}

local root_cache = {}

local configure_telescope = function()
  local telescope = require("telescope")
  local builtin = require("telescope.builtin")
  local extensions = telescope.extensions

  local githelpers = require("lib.git")
  local starts_with = require("lib.text").starts_with

  --- @param buffer_dir string
  --- @return string | nil
  local getWorkspacePath = function(buffer_dir)
    if root_cache[buffer_dir] then
      return root_cache[buffer_dir]
    end

    local result = vim.fs.find(root_files, {
      path = buffer_dir,
      upward = true,
      limit = 1,
    })

    if result[1] then
      local dir = vim.fs.dirname(result[1])
      root_cache[buffer_dir] = dir
      return dir
    end

    local dir = vim.lsp.buf.list_workspace_folders()[1]
    if dir then
      root_cache[buffer_dir] = dir
      return dir
    end
  end

  -- Choose the search dir based on the workspace, Git root, and how the current buffer's location compares to it
  local chooseSearchDir = function()
    local buffer_dir = require("telescope.utils").buffer_dir()
    local workspace_dir = getWorkspacePath(buffer_dir)

    -- Special case for config dir :)
    if string.find(buffer_dir, ".config/nvim") then
      return "~/.config/nvim"
    end

    -- Use workspace_dir if the buffer dir contains it
    if workspace_dir and starts_with(buffer_dir, workspace_dir) then
      return workspace_dir
    end

    -- Use CWD if it contains the buffer dir
    local cwd = vim.fn.getcwd()
    if string.find(buffer_dir, cwd) then
      return cwd
    end

    local git_root = githelpers.git_repo_toplevel()
    if git_root and string.find(buffer_dir, git_root) then
      return git_root
    end

    -- Finally just fall back and use the buffer dir
    return buffer_dir
  end

  local useGitIgnore = true
  --- @param dir string | nil The directory of the file
  --- @return string[]
  local function ripgrep_extra_options(dir)
    local opts = {}
    if dir and (dir:find(".config/nvim") or dir:find("/dotfiles/")) then
      opts = {
        "--hidden",
        "--glob",
        "!**/.git/*",
      }
    end

    if not useGitIgnore then
      table.insert(opts, "-u")
    end

    return opts
  end

  --- @param dir string | nil The directory of the file
  --- @param opts string[] | nil Extra ripgrep options
  --- @return string[]
  local function ripgrep_find(dir, opts)
    opts = opts or { "--files" }

    local rg_command = {
      "rg",
    }

    local hidden_opts = ripgrep_extra_options(dir)
    for i = 1, #hidden_opts do
      table.insert(rg_command, hidden_opts[i])
    end

    for i = 1, #opts do
      table.insert(rg_command, opts[i])
    end

    return rg_command
  end

  vim.api.nvim_create_user_command("BrowseGitIgnore", function()
    useGitIgnore = not useGitIgnore
    print("useGitIgnore: " .. tostring(useGitIgnore))
  end, {})

  vim.keymap.set("n", "\\", function()
    builtin.buffers()
  end, { desc = "List Buffers" })
  vim.keymap.set("n", "<space>", function()
    extensions.smart_open.smart_open({ filename_first = false })
  end, { desc = "Smart Open" })
  vim.keymap.set("n", "<leader>t", function()
    local cwd = chooseSearchDir()
    builtin.find_files({
      cwd = cwd,
      find_command = ripgrep_find(cwd),
    })
  end, { desc = "Find files from Workspace Root" })
  vim.keymap.set("n", "<leader>N", function()
    local cwd = vim.fn.expand("%:p:h")
    builtin.find_files({
      cwd = cwd,
      find_command = ripgrep_find(cwd),
    })
  end, { desc = "Find files from CWD" })
  vim.keymap.set("n", "<leader>T", function()
    local cwd = githelpers.git_repo_toplevel()
    builtin.find_files({
      cwd = cwd,
      find_command = ripgrep_find(cwd),
    })
  end, { desc = "Find files from Git Root" })
  vim.keymap.set("n", "<leader>qf", builtin.quickfix, { desc = "Search QuickFix Buffer" })
  vim.keymap.set("n", "<leader>qh", builtin.quickfixhistory, { desc = "Search QuickFix History" })
  vim.keymap.set("n", "<leader>L", builtin.loclist, { desc = "Search Location List" })
  vim.keymap.set("n", "<leader>j", builtin.jumplist, { desc = "Search Jump List" })
  vim.keymap.set("n", "<leader>g", function()
    local cwd = chooseSearchDir()
    builtin.live_grep({ cwd = cwd, additional_args = ripgrep_extra_options(cwd) })
  end, { desc = "Grep in Workspace" })
  vim.keymap.set("n", "<leader>hs", builtin.search_history, { desc = "Search History" })
  vim.keymap.set("n", "<leader>G", function()
    builtin.live_grep({ search_dirs = { githelpers.git_repo_toplevel() } })
  end, { desc = "Grep in Git Repo" })
  vim.keymap.set("n", "<leader>s", builtin.grep_string, { desc = "Grep for current string" })
  vim.keymap.set("n", "<leader>S", function()
    builtin.grep_string({ search_dirs = { githelpers.git_repo_toplevel() } })
  end, { desc = "Grep for current string in Git Repo" })
  vim.keymap.set("n", "<leader>n", function()
    extensions.file_browser.file_browser({ cwd = require("telescope.utils").buffer_dir() })
  end, { desc = "File Browser" })
  vim.keymap.set("n", "<leader>v", builtin.treesitter, { desc = "Show Treesitter Symbols" })
  vim.keymap.set("n", "<leader>R", builtin.resume, { desc = "Restore last Telescope Picker" })

  -- Go to definition
  vim.keymap.set("n", "<leader>dd", function()
    require("telescope.builtin").lsp_definitions()
  end, { silent = true, desc = "Go to definition" })
  vim.keymap.set("n", "gd", function()
    require("telescope.builtin").lsp_definitions()
  end, { silent = true, desc = "Go to definition" })

  vim.keymap.set("n", "<leader>dl", function()
    require("telescope.builtin").diagnostics({ bufnr = 0 })
  end, { silent = true, desc = "Show Document Diagnostics" })
  vim.keymap.set("n", "<leader>wl", function()
    require("telescope.builtin").diagnostics()
  end, { silent = true, desc = "Show Workspace Diagnostics" })

  vim.keymap.set("n", "<leader>dr", function()
    require("telescope.builtin").lsp_references()
  end, { silent = true, desc = "Show References" })
  vim.keymap.set("n", "gr", function()
    require("telescope.builtin").lsp_references()
  end, { silent = true, desc = "Show References" })

  vim.keymap.set("n", "<leader>ds", function()
    require("telescope.builtin").lsp_document_symbols()
  end, { silent = true, desc = "Show Document Symbols" })
  vim.keymap.set("n", "<leader>ws", function()
    require("telescope.builtin").lsp_dynamic_workspace_symbols()
  end, { silent = true, desc = "Show Workspace Symbols" })

  vim.keymap.set("n", "<leader>U", function()
    require("telescope").extensions.undo.undo()
  end, { silent = true, desc = "Show Undo History" })

  vim.keymap.set("n", "<leader>:", command_history, { desc = "Search Command History" })

  -- Override default cmdwin to use Telescope instead
  vim.keymap.set("c", "<C-f>", function()
    local filter = nil
    local cmdline = vim.fn.getcmdline()
    if cmdline then
      cmdline = cmdline:lower()
      filter = function(text)
        return text:lower():find(cmdline)
      end

      -- Clear the command line since Vim tries to execute the current contents otherwise
      vim.fn.setcmdline("")
    end

    command_history({
      filter_fn = filter,
    })
  end, { desc = "Search Command History", silent = true })

  vim.keymap.set("n", "q:", command_history, { desc = "Search Command History" })
end

return {
  -- Telescope fuzzy finder
  "nvim-lua/plenary.nvim",

  {
    "nvim-telescope/telescope.nvim",
    cond = not vim.g.vscode,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-lua/popup.nvim",
    },
    opts = {
      defaults = {
        mappings = {
          i = {
            ["<C-u>"] = false,
            ["<D-Down>"] = require("telescope.actions").cycle_history_next,
            ["<D-Up>"] = require("telescope.actions").cycle_history_prev,
          },
        },
      },
    },
    config = function(_, opts)
      require("telescope").setup(opts)
      configure_telescope()
    end,
  },

  {
    "nvim-telescope/telescope-file-browser.nvim",
    cond = not vim.g.vscode,
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      require("telescope").load_extension("file_browser")
    end,
  },

  {
    "nvim-telescope/telescope-fzy-native.nvim",
    cond = not vim.g.vscode,
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      require("telescope").load_extension("fzy_native")
    end,
  },

  {
    "debugloop/telescope-undo.nvim",
    cond = not vim.g.vscode,
    dependencies = { "nvim-telescope/telescope.nvim" },
    opts = {
      layout_strategy = "vertical",
      layout_config = {
        preview_height = 0.8,
      },
      side_by_side = true,
      vim_diff_opts = {
        ctxlen = 5,
        ignore_whitespace = true,
      },
    },
    config = function(_, opts)
      require("telescope").setup({
        extensions = {
          undo = opts,
        },
      })
      require("telescope").load_extension("undo")
    end,
  },

  {
    "danielfalk/smart-open.nvim",
    cond = not vim.g.vscode,
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "kkharji/sqlite.lua",
    },
    config = function()
      require("telescope").load_extension("smart_open")
    end,
  },
}
