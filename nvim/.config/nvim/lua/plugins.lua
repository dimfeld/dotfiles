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
}
