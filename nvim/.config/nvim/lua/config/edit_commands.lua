-- Dial does number incrementing and decrementing
local dial = require('dial.map')
vim.keymap.set("n", "<M-i>", dial.inc_normal(), {noremap = true})
vim.keymap.set("n", "<M-d>", dial.dec_normal(), {noremap = true})
vim.keymap.set("n", "g<M-i>", dial.inc_gnormal(), {noremap = true})
vim.keymap.set("n", "g<M-d>", dial.dec_gnormal(), {noremap = true})
vim.keymap.set("v", "<M-i>", dial.inc_visual(), {noremap = true})
vim.keymap.set("v", "<M-d>", dial.dec_visual(), {noremap = true})
vim.keymap.set("v", "g<M-i>",dial.inc_gvisual(), {noremap = true})
vim.keymap.set("v", "g<M-d>",dial.dec_gvisual(), {noremap = true})

require('which-key').setup{}

-- Autopairs
local npairs = require'nvim-autopairs'

MUtils.completion_confirm=function()
  if vim.fn['coc#pum#visible']() ~= 0  then
    return npairs.esc("<cr>")
  else
    return npairs.autopairs_cr()
  end
end

vim.keymap.set('i', '<CR>', MUtils.completion_confirm)

npairs.setup({
  check_ts = true,
  ignored_next_char = "[%w%.\"']", -- will ignore alphanumeric and `.` symbol
})

local Rule = require('nvim-autopairs.rule')
local cond = require('nvim-autopairs.conds')

-- Leap for quick navigation through the buffer
require('leap')
vim.keymap.set({'n'}, 'f', '<Plug>(leap-forward-to)', {noremap = false})
vim.keymap.set({'n'}, 'F', '<Plug>(leap-backward-to)', {noremap = false})
vim.keymap.set({'x', 'o'}, 'f', '<Plug>(leap-forward-till)', {noremap = false})
vim.keymap.set({'x', 'o'}, 'F', '<Plug>(leap-backward-till)', {noremap = false})

require('Comment').setup({
   pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
})
