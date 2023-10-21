vim.g.svelte_preprocessor_tags = {
  { name = 'postcss', tag = 'style', as = 'scss' }
}

vim.g.svelte_preprocessors = {'typescript', 'postcss', 'scss'}

vim.g.vim_svelte_plugin_use_typescript = 1
vim.g.vim_svelte_plugin_use_sass = 1

local auGroup = vim.api.nvim_create_augroup('CodeLangs', {})
vim.api.nvim_create_autocmd({'BufNewFile', 'BufRead'}, {
  group = auGroup,
  pattern = '*.pcss',
  callback = function()
    vim.bo.syntax = 'scss'
  end
})

require'nvim-treesitter.configs'.setup {
  ensure_installed = {
    'svelte', 'typescript'
  },
  context_commentstring = {
    enable = true,
    enable_autocmd = false,
    commentary_integration = {
      Commentary = false,
      CommentaryLine = false
    }
  },
  highlight = {
    enable = false,
    disable = { 'rust', 'javascript', 'javascript.jsx' }
  },
  indent = {
    enable = false
  },
  autopairs = { enable = true }
}
