-- Autopairs
local npairs = require'nvim-autopairs'

function pum_visible()
  return vim.fn['coc#pum#visible']() == 1
end

npairs.setup({
  check_ts = true,
  ignored_next_char = "[%w%.\"']", -- will ignore alphanumeric and `.` symbol
})

local Rule = require('nvim-autopairs.rule')
local cond = require('nvim-autopairs.conds')

-- Only add closing bracket if <CR> is hit right after the opening bracket
npairs.remove_rule('{')
npairs.add_rules({
  Rule('{', '}'):end_wise(function(opts)
    local lastChar = string.sub(vim.trim(opts.line), -1)
    return lastChar == '{' or lastChar == ')'
  end)
})

-- # Completion --

-- Tab and S-Tab navigate completion popup, if it's open
vim.keymap.set('i', '<TAB>', function()
  if pum_visible() then
    print 'pum visible'
    return vim.fn['coc#pum#next'](1)
  else
    return '<TAB>'
  end
end, { expr = true, silent = true })

vim.keymap.set('i', '<S-TAB>', function()
  if pum_visible() then
    return vim.fn['coc#pum#prev'](1)
  else
    return "<S-TAB>"
  end
end, { expr = true, silent = true })


-- Cancel confirmation when arrow key is pressed
function close_pum_when_pressed(key)
  vim.keymap.set('i', key, function()
    if pum_visible() then
      vim.fn['coc#pum#stop']()
    end

    return key
  end, { expr = true })
end

-- Close preview window when completion is done.
local auGroup = vim.api.nvim_create_augroup('completion', {})
vim.api.nvim_create_autocmd('CompleteDone', {
  group = auGroup,
  pattern = '*',
  callback = function()
    if not pum_visible() and vim.fn['getcmdwintype']() == '' then
      vim.cmd('pclose')
    end
  end
})

close_pum_when_pressed('<up>')
close_pum_when_pressed('<down>')
close_pum_when_pressed('<left>')
close_pum_when_pressed('<right>')

-- Open completion popup
vim.keymap.set('i', '<c-space>', function() vim.fn['coc#start']() end, { silent = true })

-- Allow triggering code action, such as adding import, from completion window
vim.keymap.set('i', '<leader>c', function()
  if pum_visible() then
    return vim.fn['coc#pum#confirm']()
  else
    return '<leader>c'
  end
end, { silent = true, expr = true })

-- Don't give completion messages like 'match 1 of 2' or 'The only match'
vim.opt.shortmess:append "c"
