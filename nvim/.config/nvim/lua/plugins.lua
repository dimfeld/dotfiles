return {
  -- "mattn/efm-langserver",

  -- Better terminal
  "akinsho/toggleterm.nvim",

  -- === Git Plugins ===
  {
    "tpope/vim-fugitive",
    dependencies = { "tpope/vim-rhubarb" },
  },
  {
    "ruifm/gitlinker.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      -- Due to poor design we can't disable this so set it to something that doesn't conflict.
      mappings = "<leader>123",
      opts = {
        print_url = false,
      },
    },
  },
  { "rhysd/conflict-marker.vim" },

  -- File explorer
  { "tpope/vim-vinegar", event = "VeryLazy" },
  {
    "tpope/vim-dotenv",
    priority = 1000,
    config = function()
      local path = vim.fn.expand("~/.config/nvim/.env")
      if vim.fn.filereadable(path) == 1 then
        vim.cmd("Dotenv " .. path)
      end
    end,
  },

  {
    "junegunn/fzf",
    event = "VeryLazy",
    build = function()
      vim.fn["fzf#install"]()
    end,
  },

  { "nvim-neotest/nvim-nio", lazy = true },

  {
    "folke/snacks.nvim",
    priority = 1000,
    cond = true,
    lazy = false,
    ---@class snacks.Config
    ---@field bigfile? snacks.bigfile.Config | { enabled: boolean }
    ---@field gitbrowse? snacks.gitbrowse.Config
    ---@field lazygit? snacks.lazygit.Config
    ---@field notifier? snacks.notifier.Config | { enabled: boolean }
    ---@field quickfile? { enabled: boolean }
    ---@field statuscolumn? snacks.statuscolumn.Config  | { enabled: boolean }
    ---@field terminal? snacks.terminal.Config
    ---@field toggle? snacks.toggle.Config
    ---@field styles? table<string, snacks.win.Config>
    ---@field win? snacks.win.Config
    ---@field words? snacks.words.Config
    opts = function(_, opts)
      opts = opts or {}

      opts.notifier = vim.tbl_deep_extend("force", opts.notifier or {}, {
        enabled = true,
        timeout = 5000,
        top_down = false,
      })
      opts.bigfile = vim.tbl_deep_extend("force", opts.bigfile or {}, { enabled = true })
      opts.quickfile = vim.tbl_deep_extend("force", opts.quickfile or {}, { enabled = true })
      opts.words = vim.tbl_deep_extend("force", opts.words or {}, { enabled = true })
      opts.statuscolumn = vim.tbl_deep_extend("force", opts.statuscolumn or {}, {
        enabled = false,
      })
      opts.picker = vim.tbl_deep_extend("force", opts.picker or {}, {
        layout = {
          reverse = true,
          layout = {
            box = "horizontal",
            width = 0.8,
            min_width = 120,
            height = 0.8,
            {
              box = "vertical",
              border = true,
              title = "{title} {live} {flags}",
              { win = "list", border = "none" },
              { win = "input", height = 1, border = "top" },
            },
            { win = "preview", title = "{preview}", border = true, width = 0.5 },
          },
        },
        sources = {
          explorer = {
            auto_close = true,
            focus = "input",
            jump = { close = true },
            layout = {
              preset = "default",
              preview = true,
              reverse = false,
            },
          },
        },
        win = {
          input = {
            keys = {
              ["<M-Up>"] = "explorer_up",
              ["<D-Down>"] = { "history_forward", mode = { "i", "n" } },
              ["<D-Up>"] = { "history_back", mode = { "i", "n" } },
              ["<C-u>"] = false,
              ["<C-y>"] = { "yank_paths", mode = { "i", "n" }, desc = "Yank selected paths" },
            },
          },
          list = {
            keys = {
              ["<BS>"] = "explorer_up",
              ["<M-Up>"] = "explorer_up",
              ["l"] = "confirm",
              ["h"] = "explorer_close", -- close directory
              ["a"] = "explorer_add",
              ["d"] = "explorer_del",
              ["r"] = "explorer_rename",
              ["c"] = "explorer_copy",
              ["m"] = "explorer_move",
              ["o"] = "explorer_open", -- open with system application
              ["P"] = "toggle_preview",
              ["y"] = { "explorer_yank", mode = { "n", "x" } },
              ["<C-y>"] = { "yank_paths", mode = { "n", "x" }, desc = "Yank selected paths" },
              ["p"] = "explorer_paste",
              ["u"] = "explorer_update",
              ["<c-c>"] = "tcd",
              ["<leader>/"] = "picker_grep",
              ["<c-t>"] = "terminal",
              ["."] = "explorer_focus",
              ["I"] = "toggle_ignored",
              ["H"] = "toggle_hidden",
              ["Z"] = "explorer_close_all",
              ["]g"] = "explorer_git_next",
              ["[g"] = "explorer_git_prev",
              ["]d"] = "explorer_diagnostic_next",
              ["[d"] = "explorer_diagnostic_prev",
              ["]w"] = "explorer_warn_next",
              ["[w"] = "explorer_warn_prev",
              ["]e"] = "explorer_error_next",
              ["[e"] = "explorer_error_prev",
            },
          },
        },
        actions = vim.tbl_extend("force", opts.picker and opts.picker.actions or {}, {
          yank_paths = function(picker)
            require("config.snacks_pickers").yank_selected_paths(picker)
          end,
        }),
      })

      return opts
    end,
    config = function(_, opts)
      require("snacks").setup(opts)
      require("config.snacks_pickers").setup()
    end,
    init = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        callback = function()
          local Snacks = require("snacks")
          vim.api.nvim_create_user_command("BD", function()
            Snacks.bufdelete()
          end, {})

          _G.dd = function(...)
            Snacks.debug.inspect(...)
          end
          _G.bt = function()
            Snacks.debug.backtrace()
          end
          vim.print = _G.dd

          Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
          Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
          Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
          Snacks.toggle.diagnostics():map("<leader>ud")
          Snacks.toggle.line_number():map("<leader>ul")
          Snacks.toggle
            .option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
            :map("<leader>uc")
          Snacks.toggle.treesitter():map("<leader>uT")
          Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
          Snacks.toggle.inlay_hints():map("<leader>uh")
        end,
      })
    end,
  },
}
