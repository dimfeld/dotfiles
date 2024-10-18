-- local completion_assistant = "copilot"
local completion_assistant = vim.env.COMPLETION_ASSISTANT or "codeium.nvim"
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
    -- "Exafunction/codeium.vim",
    -- branch = "main",
    "dimfeld/codeium.vim",
    branch = "all-fixes",
    dir = "~/Documents/projects/codeium.vim",
    name = "codeium.vim",
    cond = completion_assistant == "codeium.vim",
    init = function()
      vim.g.codeium_enabled = true
      vim.g.codeium_no_map_tab = true
      vim.g.codeium_idle_delay = 200
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
    "dimfeld/codeium.nvim",
    name = "codeium.nvim",
    branch = "all-fixes",
    cond = completion_assistant == "codeium.nvim",
    -- dir = "~/Documents/projects/codeium.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "hrsh7th/nvim-cmp",
      "nvim-lualine/lualine.nvim",
    },
    opts = {
      virtual_text = {
        enabled = true,
        filetypes = {
          AvanteInput = false,
        },
        key_bindings = {
          accept = "<C-]>",
          accept_line = "<C-j>",
          clear = "",
        },
      },
      enable_cmp_source = false,
    },
    config = function(_, opts)
      require("codeium").setup(opts)
      require("codeium.virtual_text").set_statusbar_refresh(require("lualine").refresh)
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
    enabled = false,
    opts = {
      backend = "ollama",
      model = "deepseek-coder-v2:16b-lite-instruct-fp16",
    },
  },
  {
    "joshuavial/aider.nvim",
    enabled = false,
    opts = {
      auto_manage_context = true,
      default_keybindings = false,
    },
  },
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

      -- Map ,ae to start edit and then enter insert mode
      vim.keymap.set("v", "<leader>ae", function()
        require("avante.api").edit()
        vim.cmd.startinsert()
      end, { noremap = true })
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
        -- Temporarily pinned until "spaces" error is fixed
        commit = "de6f057cf56cf920e9135c366fd3994536be43f4",
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
