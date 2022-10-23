local path = require('plenary.path');
local util = require('formatter.util');

vim.env.PRETTIERD_LOCAL_PRETTIER_ONLY = 'true'

local prettier_config_files = {
  '.prettierrc',
  '.prettierrc.js',
  '.prettierrc.json',
  'prettier.config.js',
  'prettier.config.cjs',
}

local prettierd = function()
  local current_path = util.get_current_buffer_file_path()
  local current_dir = vim.fs.dirname(current_path)
  local found_config = vim.fs.find(prettier_config_files, {
    path = current_dir,
    upward = true,
    type = 'file',
    limit = 1,
  })

  -- print(vim.inspect(found_config))

  local next = next
  if next(found_config) == nil then
    return nil
  end

  return {
    exe = "prettierd",
    args = { util.escape_path(current_path) },
    stdin = true,
  }
end

require('formatter').setup({
  logging = true,
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
