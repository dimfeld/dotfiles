local markdownGroup = vim.api.nvim_create_augroup('markdown', {})

vim.api.nvim_create_autocmd({'BufRead' ,'BufNewFile'}, {
  group = markdownGroup,
  pattern = '*.md',
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.formatoptions:append 't'
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = markdownGroup,
  pattern = 'markdown',
  callback = function()
    require('section-wordcount').wordcounter({})
  end
})

vim.g['asciidoctor_folding'] = 1
vim.g['asciidoctor_fenced_languages'] = {
  'sql', 'svelte', 'rust', 'bash'
}

require('section-wordcount').setup{}

local asciidocGroup = vim.api.nvim_create_augroup('AsciiDoc', {})
vim.api.nvim_create_autocmd('FileType', {
  group = asciidocGroup,
  pattern = "asciidoc",
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.shiftwidth = 2
    vim.opt_local.wrap = true
    vim.opt_local.lbr = true
    vim.opt_local.foldlevel = 99
    vim.keymap.set('n', '<Down>', 'gj', { buffer = true })
    vim.keymap.set('n', '<Up>', 'gk', { buffer = true })
    require('section-wordcount').wordcounter({
      header_char = '='
    })
  end
})
