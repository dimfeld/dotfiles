local cmdbar = require("config.telescope_commandbar")

local toggleterm = require("toggleterm")
local toggleterm_open_mapping = [[<C-\>]]

toggleterm.setup({
  size = vim.o.lines / 3,
  open_mapping = toggleterm_open_mapping,
  hide_numbers = true,
  start_in_insert = true,
  insert_mappings = false,
  -- Always restart in insert mode
  persist_mode = false,
  direction = "horizontal",
})

vim.api.nvim_create_user_command("VTerm", "ToggleTerm size=80 direction=vertical", {})
vim.api.nvim_create_user_command("Vterm", "ToggleTerm size=80 direction=vertical", {})
vim.api.nvim_create_user_command("HTerm", "ToggleTerm size=20 direction=horizontal", {})
vim.api.nvim_create_user_command("Hterm", "ToggleTerm size=20 direction=horizontal", {})

-- Tell neovim to catch these keystrokes instead of passing them through to the terminal.
function set_terminal_keymaps()
  -- This key sequence exits from "terminal" mode into command mode.
  local term_escape = [[<C-\><C-n>]]
  local tmap = function(input, command)
    vim.api.nvim_buf_set_keymap(0, "t", input, term_escape .. command, { noremap = true })
  end

  tmap("<C-h>", "<C-w>h")
  tmap("<C-j>", "<C-w>j")
  tmap("<C-k>", "<C-w>k")
  tmap("<C-l>", "<C-w>l")

  -- start/end of line
  vim.api.nvim_buf_set_keymap(0, "t", "<D-Left>", "<C-A>", { noremap = true })
  vim.api.nvim_buf_set_keymap(0, "t", "<D-Right>", "<C-E>", { noremap = true })

  vim.api.nvim_buf_set_keymap(0, "t", toggleterm_open_mapping, term_escape .. "<cmd>ToggleTerm<CR>", { noremap = true })

  -- Double-escape with timeout: press <esc> twice quickly to exit terminal mode
  -- If you don't press the second <esc> within the timeout, it sends a normal <esc>
  local esc_timer = nil
  local timeout_ms = 500 -- Adjust this value to your preference (in milliseconds)

  vim.keymap.set("t", "<esc>", function()
    if esc_timer then
      -- Second escape pressed within timeout - exit terminal mode
      esc_timer:stop()
      esc_timer = nil
      vim.cmd("stopinsert")
    else
      -- First escape - start timer
      esc_timer = vim.uv.new_timer()
      esc_timer:start(timeout_ms, 0, function()
        esc_timer = nil
        -- Timeout expired - send escape to terminal
        vim.schedule(function()
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>", true, false, true), "n", false)
        end)
      end)
    end
  end, { buffer = 0, noremap = true })
end

vim.keymap.set({ "n", "t" }, "<c-1>", function()
  toggleterm.toggle(1)
end)
vim.keymap.set({ "n", "t" }, "<c-2>", function()
  toggleterm.toggle(2)
end)
vim.keymap.set({ "n", "t" }, "<c-3>", function()
  toggleterm.toggle(3)
end)

local auGroup = vim.api.nvim_create_augroup("TerminalKeymaps", {})
vim.api.nvim_create_autocmd("TermOpen", {
  group = auGroup,
  pattern = "term://*",
  callback = function()
    set_terminal_keymaps()
    vim.cmd.DisableWhitespace()
  end,
})

cmdbar.add_commands({
  {
    name = "Vertical Terminal",
    category = "Terminal",
    action = function()
      vim.cmd("VTerm")
    end,
  },
  {
    name = "Horizontal Terminal",
    category = "Terminal",
    action = function()
      vim.cmd("HTerm")
    end,
  },
})
