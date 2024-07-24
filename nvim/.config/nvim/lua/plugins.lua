return {
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

  -- SQLite, used by various other plugins, including smart-open
  "kkharji/sqlite.lua",

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

  -- :AutoSaveToggle to automatically save files. Nice for markdown editing with live preview.
  "907th/vim-auto-save",

  -- Extra commands for working with quickfix buffer entries.
  "romainl/vim-qf",

  -- Close buffers without closing split
  {
    "qpkorr/vim-bufkill",
    init = function()
      vim.g.BufKillCreateMappings = 0
    end,
  },

  -- Performance fix for things that use CursorHold
  "antoinemadec/FixCursorHold.nvim",

  -- When saving a file, create the directories if needed.
  "jghauser/mkdir.nvim",

  -- === Editing Plugins ===
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

  -- Telescope fuzzy finder
  "nvim-lua/popup.nvim",
  "nvim-lua/plenary.nvim",

  { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },

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
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      require("telescope").load_extension("smart_open")
    end,
  },

  -- Treesitter for file syntax parsing used by other extensions
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      ensure_installed = {
        "svelte",
        "typescript",
      },
      context_commentstring = {
        enable = true,
        enable_autocmd = false,
        commentary_integration = {
          Commentary = false,
          CommentaryLine = false,
        },
      },
      matchup = {
        enable = true,
      },
      highlight = {
        enable = true,
        -- disable = { "rust", "javascript", "javascript.jsx" },
      },
      indent = {
        enable = true,
      },
      autopairs = { enable = true },
    },
    init = function()
      -- Enable treesitter-based folding
      vim.o.foldmethod = "expr"
      vim.o.foldexpr = "nvim_treesitter#foldexpr()"
      vim.o.foldenable = false
    end,
  },
  "nvim-treesitter/nvim-treesitter-textobjects",

  -- justfile highlighting
  "NoahTheDuke/vim-just",

  "mhartington/formatter.nvim",
  "mattn/efm-langserver",

  -- Better terminal
  "akinsho/toggleterm.nvim",

  -- === Git Plugins ===
  -- Enable git changes to be shown in sign column
  "airblade/vim-gitgutter",
  "tpope/vim-fugitive",

  -- === Javascript Plugins ===
  -- Typescript syntax highlighting
  "HerringtonDarkholme/yats.vim",

  -- Generate JSDoc commands based on function signature
  "heavenshell/vim-jsdoc",

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

  -- === Syntax Highlighting ===
  "gutenye/json5.vim",
  "HiPhish/jinja.vim",
  "aviator-co/av-vim-plugin",

  -- Hashicorp Tools
  "hashivim/vim-hashicorp-tools",
  "jvirtanen/vim-hcl",

  -- Markdown
  "godlygeek/tabular",
  "plasticboy/vim-markdown",
  {
    "iamcco/markdown-preview.nvim",
    ft = { "markdown" },
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
  },

  "habamax/vim-asciidoctor",

  -- Syntax highlighting for nginx
  "chr4/nginx.vim",

  -- Syntax highlighting for javascript libraries
  "othree/javascript-libraries-syntax.vim",

  -- Improved syntax highlighting and indentation
  -- "othree/yajs.vim",

  -- Intellisense Engine
  {
    "fannheyward/telescope-coc.nvim",
    dependencies = { "neoclide/coc.nvim", "nvim-telescope/telescope.nvim" },
    config = function()
      require("telescope").load_extension("coc")
    end,
  },

  {
    "leafOfTree/vim-svelte-plugin",
    init = function()
      vim.g.svelte_preprocessor_tags = {
        { name = "postcss", tag = "style", as = "scss" },
      }

      vim.g.svelte_preprocessors = { "typescript", "postcss", "scss" }

      vim.g.vim_svelte_plugin_use_typescript = 1
      vim.g.vim_svelte_plugin_use_sass = 1
    end,
  },
  "cakebaker/scss-syntax.vim",
  "rust-lang/rust.vim",
  "cespare/vim-toml",
  "mechatroner/rainbow_csv",
  -- "fatih/vim-go", -- Uncomment if needed

  -- === UI ===
  -- File explorer
  "tpope/vim-vinegar",
  "kyazdani42/nvim-web-devicons",

  {
    "junegunn/fzf",
    build = function()
      vim.fn["fzf#install"]()
    end,
  },

  -- Colorscheme
  "rktjmp/lush.nvim",
  { "rockyzhang24/arctic.nvim", branch = "v2", priority = 1000 },

  -- Customized vim status line
  "nvim-lualine/lualine.nvim",

  -- Debugging
  "nvim-neotest/nvim-nio",
  "mfussenegger/nvim-dap",
  "theHamsta/nvim-dap-virtual-text",
  "rcarriga/nvim-dap-ui",
  {
    "nvim-telescope/telescope-dap.nvim",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      require("telescope").load_extension("dap")
    end,
  },

  -- === AI Stuff ===
  -- "sourcegraph/sg.nvim", -- Uncomment if needed
  "dustinblackman/oatmeal.nvim",

  -- "github/copilot.vim", -- Uncomment if needed
  { "Exafunction/codeium.vim", branch = "main" },
  "supermaven-inc/supermaven-nvim",
  "joshuavial/aider.nvim",
}
