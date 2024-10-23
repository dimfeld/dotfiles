return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      ensure_installed = {
        "rust",
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
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
          },
        },
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = {
            ["]m"] = "@function.outer",
            ["]]"] = "@class.outer",
          },
          goto_next_end = {
            ["]M"] = "@function.outer",
            ["]["] = "@class.outer",
          },
          goto_previous_start = {
            ["[m"] = "@function.outer",
            ["[["] = "@class.outer",
          },
          goto_previous_end = {
            ["[M"] = "@function.outer",
            ["[]"] = "@class.outer",
          },
        },
        selection_modes = {
          ["@parameter.outer"] = "v", -- charwise
          ["@function.outer"] = "V", -- linewise
          ["@class.outer"] = "<c-v>", -- blockwise
        },
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-f>",
          node_incremental = "<C-f>",
          scope_incremental = "<C-g>",
          node_decremental = "<C-d>",
        },
      },
      autopairs = { enable = true },
    },
    init = function()
      -- Enable treesitter-based folding
      vim.o.foldmethod = "expr"
      vim.o.foldexpr = "nvim_treesitter#foldexpr()"
      vim.o.foldenable = false
    end,
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },
}
