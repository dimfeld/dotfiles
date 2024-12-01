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
    opts = {
      notifier = {
        enabled = true,
        timeout = 5000,
        top_down = false,
      },
      bigfile = { enabled = true },
      quickfile = { enabled = true },
      words = { enabled = true },
      statuscolumn = {
        enabled = false,
      },
    },
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
