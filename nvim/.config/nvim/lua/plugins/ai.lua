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
      local acceptCmd = "codeium#Accept()"
      local acceptKeyOpts = { silent = true, expr = true, script = true, replace_keycodes = false }
      vim.keymap.set("i", "<C-J>", acceptCmd, acceptKeyOpts)
      vim.keymap.set("i", "<C-]>", acceptCmd, acceptKeyOpts)
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
}
