local util = require('formatter.util');
local prettierd = require('formatter.defaults.prettierd');

require('formatter').setup({
  filetype = {
    css = { prettierd },
    less = { prettierd },
    pcss = { prettierd },
    javascript = { prettierd },
    json = { prettierd },
    typescript = { prettierd },
    svelte = { prettierd },
  }
})
