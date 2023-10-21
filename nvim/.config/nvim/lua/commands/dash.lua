local M = {}

function urlencode(str)
  if (str) then
    str = string.gsub(str, "\n", "\r\n")
    str = string.gsub(str, "([^%w ])",
      function(c) return string.format("%%%02X", string.byte(c)) end)
    str = string.gsub(str, " ", "+")
  end
  return str
end

-- This is for my local config of Dash and may not apply the same to yours
local docset = {
  javascript = 'js',
  typescript = 'js',
  svelte = 'js',
  python = 'py'
}

M.open_dash = function(opts)
  local query = opts.query

  local filetype = opts.filetype
  filetype = docset[filetype] or filetype

  if filetype ~= nil then
    query = filetype .. ':' .. query
  end

  vim.fn.system('open dash://' .. urlencode(query))

end

M.open_dash_on_current_word = function()
  return M.open_dash({
    filetype = vim.bo.filetype,
    query = vim.fn.expand('<cword>')
  })
end

vim.api.nvim_create_user_command('Dash', function(opts)
  local query = opts.args ~= '' and opts.args or vim.fn.expand('<cword>')
  M.open_dash({
    filetype = vim.bo.filetype,
    query = query,
  })
end, {})

return M
