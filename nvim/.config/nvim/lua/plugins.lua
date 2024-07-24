return {
  -- "mattn/efm-langserver",

  -- Better terminal
  "akinsho/toggleterm.nvim",

  -- === Git Plugins ===
  "tpope/vim-fugitive",

  -- === Javascript Plugins ===

  -- Generate JSDoc commands based on function signature
  "heavenshell/vim-jsdoc",

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

  -- === UI ===
  -- File explorer
  "tpope/vim-vinegar",

  {
    "junegunn/fzf",
    build = function()
      vim.fn["fzf#install"]()
    end,
  },

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
}
