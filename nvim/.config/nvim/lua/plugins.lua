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
      mappings = nil,
    },
  },

  -- File explorer
  { "tpope/vim-vinegar", event = "VeryLazy" },
  {
    "tpope/vim-dotenv",
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
}
