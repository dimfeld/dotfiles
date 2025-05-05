local cmdbar = require("config.telescope_commandbar")
local builtin = require("telescope.builtin")

vim.api.nvim_create_user_command("Gd", ":Gvdiffsplit!", {})
vim.api.nvim_create_user_command("Gadd", ":Git add %", {})
-- Use chunk from left side
vim.keymap.set("n", "dgl", "&diff ? ':diffget //2<CR>' : ''", { expr = true, desc = "Get diff from left side" })
-- Use chunk from right side
vim.keymap.set("n", "dgr", "&diff ? ':diffget //3<CR>' : ''", { expr = true, desc = "Get diff from right side" })
vim.keymap.set("n", "dg", ":diffget", { expr = true, desc = "Get diff" })
vim.keymap.set("n", "dgo", ":diffget", { expr = true, desc = "Get diff" })

cmdbar.add_commands({
  {
    name = "Git permalink",
    category = "Git",
    action = function()
      require("gitlinker").get_buf_range_url("n", {

        action_callback = function(url)
          -- Strip off the #L\d+ part of the URL
          local new_url = vim.split(url, "#")[1]

          -- Replace with the saved cursor position from before opening the cmdbar
          new_url = new_url .. "#L" .. cmdbar.current_cursor.start.line
          if cmdbar.current_cursor.stop.line > cmdbar.current_cursor.start.line then
            new_url = new_url .. "-L" .. cmdbar.current_cursor.stop.line
          end

          require("gitlinker.actions").copy_to_clipboard(new_url)
        end,
      })
    end,
  },
  {
    name = "Git commit current file",
    category = "Git",
    action = function()
      vim.cmd("Git commit %")
    end,
  },
  {
    name = "Git Difftool",
    category = "Git",
    action = function()
      vim.cmd("Git difftool")
    end,
  },
  {
    name = "Git Blame",
    category = "Git",
    action = function()
      vim.cmd("Git blame")
    end,
  },
  {
    name = "Git 3-way Diff",
    category = "Git",
    action = function()
      vim.cmd("Gvdiffsplit!")
    end,
  },
  { name = "Git Status", category = "Git", action = builtin.git_status },
})
