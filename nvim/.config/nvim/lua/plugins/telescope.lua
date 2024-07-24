function configure_telescope()
  local telescope = require("telescope")
  local builtin = require("telescope.builtin")
  local extensions = telescope.extensions

  local githelpers = require("lib.git")

  function getWorkspacePath()
    vim.wait(2000, function()
      return vim.g.coc_service_initialized == 1
    end, 50)
    return vim.fn.CocAction("currentWorkspacePath")
  end

  function in_config_dir()
    return vim.fn.getcwd():find(".config/nvim") ~= nil
  end

  useGitIgnore = true
  function ripgrep_extra_options()
    opts = {}
    if in_config_dir() then
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

  function ripgrep_find(opts)
    opts = opts or {}

    local rg_command = {
      "rg",
    }

    hidden_opts = ripgrep_extra_options()
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
  end, {})
  vim.keymap.set("n", "<space>", function()
    extensions.smart_open.smart_open({ filename_first = false })
  end, {})
  vim.keymap.set("n", "<leader>t", function()
    builtin.find_files({
      cwd = getWorkspacePath(),
      find_command = ripgrep_find({ "--files" }),
    })
  end, {})
  vim.keymap.set("n", "<leader>u", function()
    builtin.find_files({ find_comments = ripgrep_find() })
  end, {})
  vim.keymap.set("n", "<leader>T", function()
    builtin.find_files({
      cwd = githelpers.git_repo_toplevel(),
      find_command = ripgrep_find({ "--files" }),
    })
  end, {})
  vim.keymap.set("n", "<leader>qf", builtin.quickfix, {})
  vim.keymap.set("n", "<leader>qh", builtin.quickfixhistory, {})
  vim.keymap.set("n", "<leader>L", builtin.loclist, {})
  vim.keymap.set("n", "<leader>j", builtin.jumplist, {})
  vim.keymap.set("n", "<leader>:", builtin.command_history, {})
  vim.keymap.set("n", "<leader>g", function()
    builtin.live_grep({ cwd = getWorkspacePath(), additional_args = ripgrep_extra_options() })
  end, {})
  vim.keymap.set("n", "<leader>h", builtin.search_history, {})
  vim.keymap.set("n", "<leader>G", function()
    builtin.live_grep({ search_dirs = { githelpers.git_repo_toplevel() } })
  end, {})
  vim.keymap.set("n", "<leader>s", builtin.grep_string, {})
  vim.keymap.set("n", "<leader>S", function()
    builtin.grep_string({ search_dirs = { githelpers.git_repo_toplevel() } })
  end, {})
  vim.keymap.set("n", "<leader>n", function()
    extensions.file_browser.file_browser({ cwd = require("telescope.utils").buffer_dir() })
  end, {})
  vim.keymap.set("n", "<leader>N", extensions.file_browser.file_browser, {})
  vim.keymap.set("n", "<leader>v", builtin.treesitter, {})
  vim.keymap.set("n", "<leader>l", builtin.resume, {})
  vim.keymap.set("n", "<leader>dl", ":Telescope coc document_diagnostics<cr>", { silent = true })
  vim.keymap.set("n", "<leader>wl", ":Telescope coc workspace_diagnostics<cr>", { silent = true })
  vim.keymap.set("n", "<leader>dr", ":Telescope coc references<cr>", { silent = true })
  vim.keymap.set("n", "<leader>ds", ":Telescope coc document_symbols<cr>", { silent = true })
  vim.keymap.set("n", "<leader>ws", ":Telescope coc workspace_symbols<cr>", { silent = true })
  vim.keymap.set("n", "<leader>U", function()
    require("telescope").extensions.undo.undo()
  end, { silent = true, desc = "Show Undo History" })

  vim.api.nvim_create_user_command("Debug", extensions.dap.commands, {})
end

return {
  -- Telescope fuzzy finder
  "nvim-lua/plenary.nvim",

  {
    "nvim-telescope/telescope.nvim",
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
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      require("telescope").load_extension("file_browser")
    end,
  },

  {
    "nvim-telescope/telescope-fzy-native.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      require("telescope").load_extension("fzy_native")
    end,
  },

  {
    "debugloop/telescope-undo.nvim",
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
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "kkharji/sqlite.lua",
    },
    config = function()
      require("telescope").load_extension("smart_open")
    end,
  },

  {
    "fannheyward/telescope-coc.nvim",
    dependencies = { "neoclide/coc.nvim", "nvim-telescope/telescope.nvim" },
    config = function()
      require("telescope").load_extension("coc")
    end,
  },
}
