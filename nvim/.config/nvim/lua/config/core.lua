_G.MUtils = {}

-- Remap leader key to ,
vim.g.mapleader = ","

vim.o.mousemodel = "extend"

-- Use Lua filetype detection. This might not be needed anymore?
vim.g.do_filetype_lua = 1
vim.g.did_load_filetypes = 0

function reload_nvim_conf()
  for name, _ in pairs(package.loaded) do
    if
      name:match("^core")
      or name:match("^lsp")
      or name:match("^plugins")
      or name:match("^config")
      or name:match("^commands")
      or name:match("^helpers")
    then
      package.loaded[name] = nil
    end
  end

  vim.cmd("source" .. vim.env.MYVIMRC)
  vim.notify("Nvim configuration reloaded!", vim.log.levels.INFO)
end

vim.api.nvim_create_user_command("ReloadInit", reload_nvim_conf, {})
vim.api.nvim_create_user_command("EditInit", "e ~/.config/nvim/init.vim", {})

vim.o.undofile = true
vim.o.undolevels = 3000
vim.o.undoreload = 10000
vim.o.backupdir = vim.fn.expand("~/tmp,.,~/")
vim.o.directory = vim.fn.expand("~/tmp,.,~/") -- Where to keep swap files
vim.o.backup = true
vim.o.swapfile = false
