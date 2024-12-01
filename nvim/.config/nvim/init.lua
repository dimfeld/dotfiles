_G.MUtils = {}

-- Remap leader key to ,
vim.g.mapleader = ","
vim.g.maplocalleader = "\\"

require("config.lazy")
require("config")

if vim.g.vscode then
  require("config.vscode")
end
