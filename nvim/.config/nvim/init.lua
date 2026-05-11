_G.MUtils = {}

-- Remap leader key to ,
vim.g.mapleader = ","
vim.g.maplocalleader = "\\"
vim.g.file_browser_provider = vim.g.file_browser_provider or "telescope"

require("config.lazy")
require("config")

if vim.g.vscode then
  require("config.vscode")
end
