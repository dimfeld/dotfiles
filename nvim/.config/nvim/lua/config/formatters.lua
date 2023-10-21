local path = require('plenary.path')
local util = require('formatter.util')

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


  local _, found = next(found_config)
  -- print(vim.inspect(found))
  if found == nil then
    return nil
  end

  local config_dirname = vim.fs.dirname(found)

  return {
    exe = "prettierd",
    args = { util.escape_path(current_path) },
    cwd = config_dirname,
    stdin = true,
  }
end

local black = function()
  return {
    exe = "python3",
    args = { "-m", "black", "-q", "-" },
    stdin = true,
  }
end

require('formatter').setup({
  logging = true,
  -- log_level = vim.log.levels.TRACE,
  filetype = {
    html = { prettierd },
    css = { prettierd },
    less = { prettierd },
    pcss = { prettierd },
    postcss = { prettierd },
    javascript = { prettierd },
    json = { prettierd },
    typescript = { prettierd },
    svelte = { prettierd },
    python = { black }
  }
})

local auGroup = vim.api.nvim_create_augroup('Autoformat', {})
vim.api.nvim_create_autocmd('BufWritePost', {
  group = auGroup,
  pattern = '*',
  callback = function() vim.cmd.FormatWrite() end,
})

vim.api.nvim_create_user_command('Format', function()
  vim.fn.CocAction('runCommand', 'editor.action.formatDocument')
end, {})
