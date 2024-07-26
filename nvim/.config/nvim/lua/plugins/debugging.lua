return {
  {
    "mfussenegger/nvim-dap",
    ft = { "c", "cpp", "rust" },
    config = function()
      local dap = require("dap")
      vim.keymap.set("n", "<F1>", dap.terminate)
      vim.keymap.set("n", "<F6>", dap.toggle_breakpoint)
      vim.keymap.set("n", "<F7>", dap.continue)
      vim.keymap.set("n", "<F8>", dap.step_over)
      vim.keymap.set("n", "<F9>", dap.step_out)
      vim.keymap.set("n", "<F10>", dap.step_into)
      vim.keymap.set("n", "<F11>", dap.pause)
      vim.keymap.set("n", "<F56>", dap.down) -- <A-F8>
      vim.keymap.set("n", "<F57>", dap.up) -- <A-F9>

      -- point dap to the installed cpptools, if you don't use mason, you'll need to change `cpptools_path`
      --local cpptools_path = vim.fn.stdpath("data").."/mason/packages/cpptools/extension/debugAdapters/bin/OpenDebugAD7"
      --dap.adapters.cppdbg = {
      --    id = 'cppdbg',
      --    type = 'executable',
      --    command = cpptools_path,
      --}

      -- local rr_dap = require("nvim-dap-rr")
      -- rr_dap.setup({
      --     mappings = {
      --         -- you will probably want to change these defaults to that they match
      --         -- your usual debugger mappings
      --         continue = "<F7>",
      --         step_over = "<F8>",
      --         step_out = "<F9>",
      --         step_into = "<F10>",
      --         reverse_continue = "<F19>", -- <S-F7>
      --         reverse_step_over = "<F20>", -- <S-F8>
      --         reverse_step_out = "<F21>", -- <S-F9>
      --         reverse_step_into = "<F22>", -- <S-F10>
      --         -- instruction level stepping
      --         step_over_i = "<F32>", -- <C-F8>
      --         step_out_i = "<F33>", -- <C-F8>
      --         step_into_i = "<F34>", -- <C-F8>
      --         reverse_step_over_i = "<F44>", -- <SC-F8>
      --         reverse_step_out_i = "<F45>", -- <SC-F9>
      --         reverse_step_into_i = "<F46>", -- <SC-F10>
      --     }
      -- })
      -- dap.configurations.rust = { rr_dap.get_rust_config() }
      -- dap.configurations.cpp = { rr_dap.get_config() }
    end,
  },

  { "theHamsta/nvim-dap-virtual-text", ft = { "c", "cpp", "rust" } },

  {
    "nvim-telescope/telescope-dap.nvim",
    ft = { "c", "cpp", "rust" },
    dependencies = { "mfussenegger/nvim-dap", "nvim-telescope/telescope.nvim" },
    config = function()
      local telescope = require("telescope")
      telescope.load_extension("dap")

      local extensions = telescope.extensions
      vim.api.nvim_create_user_command("Debug", extensions.dap.commands, {})
    end,
  },

  {
    "rcarriga/nvim-dap-ui",
    ft = { "c", "cpp", "rust" },
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      dapui.setup()
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end,
  },
}
