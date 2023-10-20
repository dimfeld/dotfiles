vim.keymap.set('n', '<leader>dd', '<Plug>(coc-definition)', { silent = true })
vim.keymap.set('n', '<leader>dj', '<Plug>(coc-implementation)', { silent = true })
vim.keymap.set('n', '<leader>dg', '<Plug>(coc-diagnostic-info)', { silent = true })
vim.keymap.set('n', '<leader>rn', '<Plug>(coc-rename)', { silent = true })
vim.keymap.set('n', '[G', '<Plug>(coc-diagnostic-prev)', { silent = true })
vim.keymap.set('n', ']G', '<Plug>(coc-diagnostic-next)', { silent = true })
vim.keymap.set('n', '[g', '<Plug>(coc-diagnostic-prev-error)', { silent = true })
vim.keymap.set('n', ']g', '<Plug>(coc-diagnostic-next-error)', { silent = true })

vim.keymap.set('n', '<leader>al', '<Plug>(coc-codeaction-line)', { silent = true })
vim.keymap.set('n', '<leader>ac', '<Plug>(coc-codeaction-cursor)', { silent = true })
vim.keymap.set('n', '<leader>af', '<Plug>(coc-codeaction)', { silent = true })


vim.g['coc_global_extensions'] = {
  'coc-css',
  'coc-eslint',
  'coc-git',
  'coc-go',
  'coc-html',
  'coc-json',
  'coc-pyright',
  'coc-rust-analyzer',
  'coc-tsserver',
  'coc-xml',
  '@yaegassy/coc-tailwindcss3'
}
