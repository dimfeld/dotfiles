local cmdbar = require("config.telescope_commandbar")
local builtin = require("telescope.builtin")

vim.api.nvim_create_user_command("Gd", ":Gvdiffsplit!", {})
vim.api.nvim_create_user_command("Gadd", ":Git add %", {})
-- Use chunk from left side
vim.keymap.set("n", "dgl", "&diff ? ':diffget //2<CR>' : ''", { expr = true, desc = "Get diff from left side" })
-- Use chunk from right side
vim.keymap.set("n", "dgr", "&diff ? ':diffget //3<CR>' : ''", { expr = true, desc = "Get diff from right side" })

cmdbar.add_commands({
  { name = "Git permalink", category = "Git", coc_cmd = "git.copyPermalink" },
  { name = "Git blame popup", category = "Git", coc_cmd = "git.showBlameDoc" },
  { name = "Open line in Github", category = "Git", coc_cmd = "git.browserOpen" },
  { name = "Show last Git commit", category = "Git", coc_cmd = "git.showCommit" },
  { name = "Undo Git chunk", category = "Git", coc_cmd = "git.chunkUndo" },
  { name = "Unstage Git chunk", category = "Git", coc_cmd = "git.chunkUnstage" },
  { name = "Stage Git chunk", category = "Git", coc_cmd = "git.chunkStage" },
  { name = "Git chunk Info", category = "Git", coc_cmd = "git.chunkInfo" },
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
      vim.cmd("Gvdiffsplit")
    end,
  },
  { name = "Git Status", category = "Git", action = builtin.git_status },
})
