-- Dial does number incrementing and decrementing
local dial = require('dial.map')
vim.keymap.set("n", "<M-i>", dial.inc_normal())
vim.keymap.set("n", "<M-d>", dial.dec_normal())
vim.keymap.set("n", "g<M-i>", dial.inc_gnormal())
vim.keymap.set("n", "g<M-d>", dial.dec_gnormal())
vim.keymap.set("v", "<M-i>", dial.inc_visual())
vim.keymap.set("v", "<M-d>", dial.dec_visual())
vim.keymap.set("v", "g<M-i>",dial.inc_gvisual())
vim.keymap.set("v", "g<M-d>",dial.dec_gvisual())

require('which-key').setup{}

-- # Buffer Navigation --

-- Quick move cursor from insert mode
-- These map to cmd/option + arrow keys
vim.keymap.set('i', '<C-a>', '<C-o>^', {})
vim.keymap.set('i', '<C-e>', '<C-o>$', {})
vim.keymap.set('n', '<C-a>', '^', {})
vim.keymap.set('n', '<C-e>', '$', {})

vim.keymap.set('i', '<C-Left>', '<C-o>^', {})
vim.keymap.set('i', '<C-Right>', '<C-o>$', {})
vim.keymap.set('n', '<C-Left>', '^', {})
vim.keymap.set('n', '<C-Right>', '$', {})

vim.keymap.set('i', '<M-h>', '<C-o>b', {})
vim.keymap.set('i', '<M-l>', '<C-o>w', {})
vim.keymap.set('n', '<M-h>', 'b', {})
vim.keymap.set('n', '<M-l>', 'w', {})

vim.keymap.set('i', '<M-g>', '<C-o>^', {})
vim.keymap.set('i', '<M-;>', '<C-o>$', {})
vim.keymap.set('n', '<M-g>', '^', {})
vim.keymap.set('n', '<M-;>', '$', {})

vim.keymap.set('i', '<M-Left>', '<C-o>b', {})
vim.keymap.set('i', '<M-Right>', '<C-o>w', {})
vim.keymap.set('n', '<M-Left>', 'b', {})
vim.keymap.set('n', '<M-Right>', 'w', {})

vim.keymap.set('i', '<M-b>', '<C-o>b', {})
vim.keymap.set('i', '<M-f>', '<C-o>w', {})
vim.keymap.set('n', '<M-b>', 'b', {})
vim.keymap.set('n', '<M-f>', 'w', {})


-- Quick window switching
vim.keymap.set('n', '<C-h>', '<C-w>h')
vim.keymap.set('n', '<C-j>', '<C-w>j')
vim.keymap.set('n', '<C-k>', '<C-w>k')
vim.keymap.set('n', '<C-l>', '<C-w>l')
vim.keymap.set('n', '<leader>p', ':b#<CR>', { silent = true })

-- Leap for quick navigation through the buffer
require('leap')
vim.keymap.set({'n'}, 'f', '<Plug>(leap-forward-to)', {noremap = false})
vim.keymap.set({'n'}, 'F', '<Plug>(leap-backward-to)', {noremap = false})
vim.keymap.set({'x', 'o'}, 'f', '<Plug>(leap-forward-till)', {noremap = false})
vim.keymap.set({'x', 'o'}, 'F', '<Plug>(leap-backward-till)', {noremap = false})

-- # Comments
vim.keymap.set('n', '<leader>c', 'gcc', { remap = true })
vim.keymap.set('v', '<leader>c', 'gc', { remap = true })
require('Comment').setup({
   pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
})

-- vim-better-whitespace
-- Strip whitespace from end of line throughout entire file
vim.keymap.set('n', '<leader>ww', ':StripWhitespace<CR>', { silent = true })


-- # Registers --

-- Delete current visual selection and dump in black hole register before pasting
-- Used when you want to paste over something without it getting copied to
-- Vim's default buffer
vim.keymap.set('v', '<leader>p', '"_dP', {})

-- Delete current selection without yanking
vim.keymap.set('v', '<leader>d', '"_d', {})

-- Copy last yanked/deleted text into register a.
-- For when you want to save into a register but forgot when you ran delete.
vim.keymap.set('n', '<leader>y', '<cmd>let @a=@"<CR>', { silent = true })

-- # Macros

-- Quick run macro q
vim.keymap.set('n', '<Tab>', '@q', {})
-- Clear macro q at startup to prevent old ones from running by mistake
vim.fn.setreg('q', '')

-- When a visual range is selected, run a macro over each line in the range
vim.keymap.set('x', '@', function()
    local macro_key = vim.fn.nr2char(vim.fn.getchar())
    print("@" .. macro_key)
    return ":normal @" .. macro_key .. '<CR>'
  end, { expr = true, silent = true }
)

-- # File System

-- Reload changed files automatically
vim.o.autoread = true

-- Preload :e command with directory of current buffer.
vim.keymap.set('n', '<leader>e', ':e %:h/', {})

-- # Search

vim.o.incsearch = true
-- Ignore case in search unless the search has an uppercase letter
vim.o.ignorecase = true
vim.o.smartcase = true

-- Repeat last replace across selected lines
vim.keymap.set('x', '&', ":'<,'>&&<CR>", { silent = true })
-- Clear search highlighting
vim.keymap.set({'n', 'x'}, '<leader>/', '<cmd>nohlsearch<CR>', { silent = true })

