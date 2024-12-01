local M = {}

local function get_floating_preview_window()
  for _, winid in pairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_get_config(winid).zindex then
      return winid
    end
  end
end

local function toggle_signature_help()
  local floating_preview_window = get_floating_preview_window()
  if floating_preview_window then
    vim.api.nvim_win_close(floating_preview_window, true)
  else
    vim.lsp.buf.signature_help()
  end
end

local function configure_lsp_keymaps()
  if vim.g.vscode then
    vim.keymap.set("i", "<C-k>", vim.lsp.buf.signature_help, { silent = true, desc = "Signature help" })
  else
    vim.keymap.set("i", "<C-k>", toggle_signature_help, {})
  end

  -- Go to implementation
  vim.keymap.set("n", "<leader>dj", vim.lsp.buf.implementation, { silent = true, desc = "Go to implementation" })

  -- Rename symbol
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { silent = true, desc = "Rename symbol" })

  if not vim.g.vscode then
    -- Show diagnostic information
    vim.keymap.set("n", "<leader>dg", vim.diagnostic.open_float, { silent = true, desc = "Show diagnostic info" })

    -- Navigate diagnostics
    vim.keymap.set("n", "[G", vim.diagnostic.goto_prev, { silent = true, desc = "Previous diagnostic" })
    vim.keymap.set("n", "]G", vim.diagnostic.goto_next, { silent = true, desc = "Next diagnostic" })

    -- Navigate errors
    vim.keymap.set("n", "[g", function()
      vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })
    end, { silent = true, desc = "Previous error" })
    vim.keymap.set("n", "]g", function()
      vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
    end, { silent = true, desc = "Next error" })

    -- Code actions
    vim.keymap.set("n", "<leader>al", function()
      local cursor = vim.fn.getpos(".")
      vim.lsp.buf.code_action({
        range = {
          start = { cursor[2], 0 },
          ["end"] = { cursor[2], 1000 },
        },
      })
    end, { silent = true, desc = "Code action on line" })

    vim.keymap.set("n", "<leader>ac", function()
      vim.lsp.buf.code_action()
    end, { silent = true, desc = "Code action at cursor" })
  end
end

M.setup = function()
  configure_lsp_keymaps()
end

return M
