return {
  -- "mattn/efm-langserver",

  -- Better terminal
  "akinsho/toggleterm.nvim",

  -- === Git Plugins ===
  "tpope/vim-fugitive",

  -- File explorer
  { "tpope/vim-vinegar", event = "VeryLazy" },

  {
    "junegunn/fzf",
    event = "VeryLazy",
    build = function()
      vim.fn["fzf#install"]()
    end,
  },

  { "nvim-neotest/nvim-nio", lazy = true },
}
