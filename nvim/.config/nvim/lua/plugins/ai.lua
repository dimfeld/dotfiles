local cmdbar = require("config.snacks_commandbar")

-- local completion_assistant = "copilot"
local completion_assistant = vim.env.COMPLETION_ASSISTANT or "codeium.nvim"
if vim.g.vscode then
  completion_assistant = ""
end
-- local completion_assistant = "supermaven"

return {
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
    enabled = false,
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
      enable_cmp_source = false,
      quiet = true,
      virtual_text = {
        enabled = true,
        key_bindings = {
          accept = "<C-]>",
          -- accept_line = "<C-j>",
          -- clear = "",
        },
      },
    },
    config = function(_, opts)
      require("codeium").setup(opts)
      require("codeium.virtual_text").set_statusbar_refresh(require("lualine").refresh)

      cmdbar.add_commands({
        {
          name = "Codeium Chat",
          category = "AI",
          action = function()
            vim.cmd("Codeium Chat")
          end,
        },
      })
    end,
  },
  {
    "supermaven-inc/supermaven-nvim",
    cond = completion_assistant == "supermaven",
    enabled = false,
    event = "VeryLazy",
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
    event = "VeryLazy",
    cond = not vim.g.vscode,
    opts = {
      backend = "ollama",
      model = "deepseek-coder-v2:16b-lite-instruct-fp16",
    },
  },
  {
    "joshuavial/aider.nvim",
    enabled = false,
    event = "VeryLazy",
    cond = not vim.g.vscode,
    opts = {
      auto_manage_context = true,
      default_keybindings = false,
    },
    config = function(_, opts)
      require("aider").setup(opts)
      cmdbar.add_commands({
        {
          name = "Aider",
          category = "AI",
          action = function()
            AiderOpen()
          end,
        },
        {
          name = "Aider Background",
          category = "AI",
          action = function()
            AiderBackground()
          end,
        },
      })
    end,
  },
  {
    "coder/claudecode.nvim",
    name = "claudecode.nvim",
    enabled = false,
    dir = "~/Documents/src/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    opts = {
      terminal_cmd = "claude --model sonnet",
      terminal = {
        ---@module "snacks"
        ---@type snacks.win.Config|{}
        snacks_win_opts = {
          keys = {
            claude_hide = {
              "<C-,>",
              function(self)
                self:hide()
              end,
              mode = "t",
              desc = "Hide",
            },
          },
        },
      },
      cwd_provider = function(ctx)
        return require("lib.git").git_repo_toplevel() or ctx.file_dir or ctx.cwd
      end,
      focus_after_send = true,
      -- Wait longer for Claude Code to connect when there's a mention to send
      queue_timeout = 10000,
      diff_opts = {
        keep_terminal_focus = true,
        open_in_current_tab = false,
      },
    },
    config = function(_, opts)
      require("claudecode").setup(opts)

      cmdbar.add_commands({
        {
          name = "Claude Code",
          category = "AI",
          action = function()
            vim.cmd("ClaudeCodeFocus")
          end,
        },
        {
          name = "Claude Code - Toggle",
          category = "AI",
          action = function()
            vim.cmd("ClaudeCode")
          end,
        },
        {
          name = "Claude Code - Continue",
          category = "AI",
          action = function()
            vim.cmd("ClaudeCode --continue")
          end,
        },
        {
          name = "Claude Code - Resume",
          category = "AI",
          action = function()
            vim.cmd("ClaudeCode --resume")
          end,
        },
        {
          name = "Claude Code - Select Model",
          category = "AI",
          action = function()
            vim.cmd("ClaudeCodeSelectModel")
          end,
        },
      })
    end,
    event = "VeryLazy",
    keys = {
      -- { "<leader>a", nil, desc = "AI/Claude Code" },
      -- { "<leader>at", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
      -- { "<leader>as", "<cmd>ClaudeCodeAdd %:p<cr>", mode = "n", desc = "Add current buffer" },
      -- { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },

      { "<C-,>", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
      -- { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
      -- { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
      -- { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
      -- { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
      -- {
      --   "<leader>as",
      --   "<cmd>ClaudeCodeTreeAdd<cr>",
      --   desc = "Add file",
      --   ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw" },
      -- },
      -- -- Diff management
      -- { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
      -- { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
    },
  },
  {
    "dimfeld/codex.nvim",
    enabled = true,
    dependencies = { "folke/snacks.nvim" },
    event = "VeryLazy",
    -- dir = "~/Documents/projects/codex.nvim",
    keys = {
      { "<leader>a", nil, desc = "AI/Codex" },
      { "<leader>at", "<cmd>Codex<cr>", desc = "Toggle Codex" },
      { "<leader>as", "<cmd>CodexHere<cr>", mode = "n", desc = "Add current selection" },
      { "<leader>as", ":'<,'>CodexHere<cr>", mode = "v", desc = "Add current selection" },
      { "<leader>am", "<cmd>CodexHere mini<cr>", mode = "n", desc = "Add current selection" },
      { "<leader>am", ":'<,'>CodexHere mini<cr>", mode = "v", desc = "Add current selection" },
    },
    opts = {
      focus_existing_on_here = true,
      presets = {
        mini = {
          args = { "--model", "gpt-5.4-mini" },
        },
        spark = {
          args = { "--model", "gpt-5.3-codex-spark", "-c", "model_reasoning_effort=high" },
        },
      },
      codex = {
        args = { "--model", "gpt-5.3-codex-spark", "-c", "model_reasoning_effort=high" },
      },
    },
  },
}
