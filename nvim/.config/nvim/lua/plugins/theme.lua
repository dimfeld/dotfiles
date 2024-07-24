function setup_arctic()
  local auGroup = vim.api.nvim_create_augroup("ArcticTheme", {})

  vim.api.nvim_create_autocmd("ColorScheme", {
    group = highlightGroup,
    pattern = "arctic",
    callback = function()
      vim.cmd([[
      hi! CocMenuSel ctermbg=7 ctermfg=0 guifg=#111111 guibg=#aaaaff

      " Make background transparent for many things
      hi Normal ctermbg=NONE guibg=NONE
      " hi NonText ctermbg=NONE guibg=NONE
      " hi LineNr ctermfg=NONE guibg=NONE
      " hi SignColumn ctermfg=NONE guibg=NONE

      " Darker end of buffer. No need to set it apart when line numbers are enabled.
      hi EndOfBuffer ctermbg=NONE ctermfg=NONE guibg=#101010 guifg=#101010

      " Hide characters in line between panes
      hi VertSplit gui=NONE guifg=#101010 guibg=#101010
      hi clear WinSeparator
      hi link WinSeparator VertSplit

      hi CocInlayHint ctermfg=73 ctermbg=235 guifg=#999999 guibg=#222222

      hi Search guibg=#825335
      " Light pink for codeium/copilot. Easy to read but also clearly not part of the existing text
      hi CodeiumSuggestion guifg=#eeaaaa ctermfg=10
      hi CopilotSuggestion guifg=#eeaaaa ctermfg=10

      " Tone down Treesitter styles a bit.
      hi @variable guifg=None
      hi @variable.member guifg=None
      hi! link @module PreProc
      hi! link @type Normal
    ]])
    end,
  })

  vim.cmd([[ colorscheme arctic ]])
end

return {
  {
    "kyazdani42/nvim-web-devicons",
    event = "VeryLazy",
  },

  {
    "rockyzhang24/arctic.nvim",
    dependencies = { "rktjmp/lush.nvim" },
    branch = "v2",
    priority = 1000,
    config = setup_arctic,
  },
}
