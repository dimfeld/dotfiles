return {
  { "dimfeld/section-wordcount.nvim", lazy = true, opts = {} },

  -- SQLite, used by various other plugins, including smart-open
  "kkharji/sqlite.lua",

  -- Support library for plugins to enable repeating via .
  "tpope/vim-repeat",

  -- Better increment/decrement
  "monaqa/dial.nvim",

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

  -- Improved motion in Vim
  "ggandor/leap.nvim",

  -- Autoadd closing parentheses, brackets, etc.
  "windwp/nvim-autopairs",

  -- Show popup with key combo info
  -- Disabled because it's causing problems
  -- { "folke/which-key.nvim", opts = {} },

  -- Telescope fuzzy finder
  "nvim-lua/popup.nvim",
  "nvim-lua/plenary.nvim",
  "nvim-telescope/telescope.nvim",
  "nvim-telescope/telescope-file-browser.nvim",
  "nvim-telescope/telescope-fzy-native.nvim",

  "danielfalk/smart-open.nvim",

  -- Treesitter for file syntax parsing used by other extensions
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
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
  { "neoclide/coc.nvim", branch = "release" },
  "fannheyward/telescope-coc.nvim",

  "leafOfTree/vim-svelte-plugin",
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
  { "rockyzhang24/arctic.nvim", branch = "v2" },

  -- Customized vim status line
  "nvim-lualine/lualine.nvim",

  -- Debugging
  "nvim-neotest/nvim-nio",
  "mfussenegger/nvim-dap",
  "theHamsta/nvim-dap-virtual-text",
  "rcarriga/nvim-dap-ui",
  "nvim-telescope/telescope-dap.nvim",

  -- === AI Stuff ===
  -- "sourcegraph/sg.nvim", -- Uncomment if needed
  "dustinblackman/oatmeal.nvim",

  -- "github/copilot.vim", -- Uncomment if needed
  { "Exafunction/codeium.vim", branch = "main" },
  "supermaven-inc/supermaven-nvim",
  "joshuavial/aider.nvim",
}
