-- local completion_assistant = "copilot"
local completion_assistant = "codeium"
-- local completion_assistant = "sourcegraph"
-- local completion_assistant = "supermaven"

return {
  { "sourcegraph/sg.nvim", cond = completion_assistant == "sourcegraph" },

  {
    "github/copilot.vim",
    cond = completion_assistant == "copilot",
    enabled = false,
    init = function()
      vim.g.copilot_no_tab_map = true
      vim.g.copilot_filetypes = {
        markdown = true,
      }
    end,
    config = function()
      local acceptCmd = 'copilot#Accept("")'
      local acceptKeyOpts = { silent = true, expr = true, script = true, replace_keycodes = false }
      vim.keymap.set("i", "<C-J>", acceptCmd, acceptKeyOpts)
      vim.keymap.set("i", "<C-]>", acceptCmd, acceptKeyOpts)
    end,
  },
  {
    "Exafunction/codeium.vim",
    -- dir = "~/Documents/projects/codeium.vim",
    name = "codeium.vim",
    branch = "main",
    cond = completion_assistant == "codeium",
    init = function()
      vim.g.codeium_enabled = true
      vim.g.codeium_no_map_tab = true
    end,
    opts = {
      enable_chat = true,
    },
    config = function(_, opts)
      local acceptKeyOpts = { silent = true, expr = true, script = true, replace_keycodes = false }
      vim.keymap.set("i", "<C-J>", "codeium#AcceptNextLine()", acceptKeyOpts)
      vim.keymap.set("i", "<C-]>", "codeium#Accept()", acceptKeyOpts)
      vim.keymap.set("i", "<C-p>", vim.fn["codeium#Complete"])
    end,
  },
  {
    "supermaven-inc/supermaven-nvim",
    cond = completion_assistant == "supermaven",
    opts = {
      keymaps = {
        accept_suggestion = "<C-]>",
        clear_suggestion = "<C-J>",
        accept_word = "<M-]>",
      },
      color = {
        suggestion_color = "#eeaaaa",
        cterm = 10,
      },
    },
  },

  {
    "dustinblackman/oatmeal.nvim",
    opts = {
      backend = "ollama",
      model = "deepseek-coder-v2:16b-lite-instruct-fp16",
    },
  },
  { "joshuavial/aider.nvim", opts = {
    auto_manage_context = true,
    default_keybindings = false,
  } },
  {
    "yetone/avante.nvim",
    enabled = true,
    event = "VeryLazy",
    build = "make", -- This is Optional, only if you want to use tiktoken_core to calculate tokens count
    opts = {
      -- add any opts here
    },
    config = function(_, opts)
      require("avante").setup(opts)
      require("avante_lib").load()
    end,
    dependencies = {
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below is optional, make sure to setup it properly if you have lazy=true
      "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
      {
        -- support for image pasting
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
          },
        },
      },
      {
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
          file_types = { "Avante" },
        },
        ft = { "Avante" },
      },
    },
  },
  {
    "pieces-app/plugin_neovim",
    enabled = false,
    dependencies = {
      "kyazdani42/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
      "hrsh7th/nvim-cmp",
    },
    opts = {
      host = "http://localhost:1000",
    },
    config = function(_, opts)
      require("pieces.config").host = opts.host

      require("config.telescope_commandbar").add_commands({
        {
          name = "Pieces Copilot",
          category = "AI",
          action = function()
            vim.fn["PiecesCopilot"]()
          end,
        },
        {
          name = "Pieces Conversations",
          category = "AI",
          action = function()
            vim.fn["PiecesConversations"]()
          end,
        },
        {
          name = "Pieces Snippets",
          category = "AI",
          action = function()
            vim.fn["PiecesSnippets"]()
          end,
        },
      })
    end,
  },
}
