return {
  -- Support library for plugins to enable repeating via .
  "tpope/vim-repeat",

  -- Better increment/decrement
  {
    "monaqa/dial.nvim",
    config = function()
      local dial = require("dial.map")
      vim.keymap.set("n", "<M-i>", dial.inc_normal(), { desc = "Increment number" })
      vim.keymap.set("n", "<M-d>", dial.dec_normal(), { desc = "Decrement number" })
      vim.keymap.set("n", "g<M-i>", dial.inc_gnormal(), { desc = "Stacking increment" })
      vim.keymap.set("n", "g<M-d>", dial.dec_gnormal(), { desc = "Stacking decrement" })
      vim.keymap.set("v", "<M-i>", dial.inc_visual(), { desc = "Increment number" })
      vim.keymap.set("v", "<M-d>", dial.dec_visual(), { desc = "Decrement number" })
      vim.keymap.set("v", "g<M-i>", dial.inc_gvisual(), { desc = "Stacking increment" })
      vim.keymap.set("v", "g<M-d>", dial.dec_gvisual(), { desc = "Stacking decrement" })
    end,
  },

  -- Trailing whitespace highlighting & automatic fixing
  "ntpeters/vim-better-whitespace",

  -- Utilities for moving/renaming/deleting files
  -- fork without <CR> remapping which interferes with autopairs
  "dimfeld/vim-eunuch",

  "tpope/vim-unimpaired",
  "tpope/vim-surround",

  -- Better text replacement for replacing multiple similar words (different cases, etc)
  "tpope/vim-abolish",

  -- Leap for quick navigation through the buffer
  {
    "ggandor/leap.nvim",
    config = function()
      vim.keymap.set({ "n", "x", "o" }, "s", "<Plug>(leap-forward-to)", { noremap = false })
      vim.keymap.set({ "n", "x", "o" }, "S", "<Plug>(leap-backward-to)", { noremap = false })
      vim.keymap.set({ "x", "o" }, "x", "<Plug>(leap-forward-till)", { noremap = false })
      vim.keymap.set({ "x", "o" }, "X", "<Plug>(leap-backward-till)", { noremap = false })
      vim.keymap.set({ "n", "x", "o" }, "gs", "<Plug>(leap-from-window)", { noremap = false })
    end,
  },

  {
    "andymass/vim-matchup",
    init = function()
      -- The plugin works around matchit by default but this keeps it from needing to do so.
      vim.g.loaded_matchit = 1
    end,
  },

  -- Autoadd closing parentheses, brackets, etc.
  {
    "windwp/nvim-autopairs",
    opts = {
      check_ts = true,
      ignored_next_char = "[%w%.\"']", -- will ignore alphanumeric and `.` symbol
    },
  },

  -- Show popup with key combo info
  -- Disabled because it's causing problems
  -- { "folke/which-key.nvim", opts = {} },

  -- Comment toggling
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    init = function()
      vim.g.skip_ts_context_commentstring_module = true

      local get_option = vim.filetype.get_option
      vim.filetype.get_option = function(filetype, option)
        return option == "commentstring" and require("ts_context_commentstring.internal").calculate_commentstring()
          or get_option(filetype, option)
      end
    end,
    opts = {
      enable = true,
      enable_autocmd = false,
      commentary_integration = {
        Commentary = false,
        CommentaryLine = false,
      },
    },
  },
  "tpope/vim-commentary",
  "numToStr/Comment.nvim",

  -- Extra commands for working with quickfix buffer entries.
  "romainl/vim-qf",

  -- Close buffers without closing split
  {
    "qpkorr/vim-bufkill",
    init = function()
      vim.g.BufKillCreateMappings = 0
    end,
  },

  -- When saving a file, create the directories if needed.
  "jghauser/mkdir.nvim",

  -- :AutoSaveToggle to automatically save files. Nice for markdown editing with live preview.
  "907th/vim-auto-save",

  {
    "dimfeld/section-wordcount.nvim",
    lazy = true,
    ft = { "markdown", "asciidoc" },
    config = function()
      require("section-wordcount").setup({})

      local auGroup = vim.api.nvim_create_augroup("section-wordcount", {})
      vim.api.nvim_create_autocmd("FileType", {
        group = auGroup,
        pattern = "markdown",
        callback = function()
          require("section-wordcount").wordcounter({})
        end,
      })

      vim.api.nvim_create_autocmd("FileType", {
        group = auGroup,
        pattern = "asciidoc",
        callback = function()
          require("section-wordcount").wordcounter({
            header_char = "=",
          })
        end,
      })
    end,
  },
}
