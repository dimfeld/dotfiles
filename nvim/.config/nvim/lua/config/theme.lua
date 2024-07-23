vim.o.number = true
vim.o.termguicolors = true
vim.o.guifont = "Inconsolata:h14"

vim.g.signify_sign_delete = "-"

-- Vertical split character is a space (hide it)
vim.o.fillchars = "vert:."
-- Set preview window to appear at bottom
vim.o.splitbelow = true

-- For Warp
--vim.o.mousescroll = 'ver:2,hor:4'

vim.o.textwidth = 120
vim.opt.formatoptions:remove("t")
vim.o.wrap = false

vim.o.cmdheight = 1

-- Disable line/column number in status line since lualine handles it
vim.o.ruler = false

-- Don't show last command
vim.o.showcmd = false

vim.o.redrawtime = 2000
-- Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
-- delays and poor user experience.
vim.o.updatetime = 300
-- Always show sign column so that it doesn't shift the buffer around when it
-- shows up
vim.o.signcolumn = "yes"

-- Don't highlight current cursor line
vim.o.cursorline = false

-- Setting for cursorhold workaround plugin
vim.g["cursorhold_updatetime"] = 100

-- Don't display mode in command line (lualine already shows it)
vim.o.showmode = false

-- Set floating window to be slightly transparent
vim.o.winblend = 20
-- Warp needs this instead
-- set winblend=0

vim.o.synmaxcol = 3000
local highlightGroup = vim.api.nvim_create_augroup("Highlighting", {})
vim.api.nvim_create_autocmd("BufEnter", {
  group = highlightGroup,
  pattern = "*",
  callback = function()
    vim.cmd("syntax sync minlines=1000")
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = highlightGroup,
  pattern = { "vim", "lua" },
  callback = function()
    vim.treesitter.start()
  end,
})

-- Customize colors
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

-- Preview window color override
vim.api.nvim_create_autocmd("WinEnter", {
  group = highlightGroup,
  pattern = "*",
  callback = function()
    if vim.wo.previewwindow then
      vim.wo.winhighlight = "Normal:MarkdownError"
    end
  end,
})

vim.cmd([[
  " Editor theme
  colorscheme arctic

  " Reload icons after init source
  if exists('g:loaded_webdevicons')
    call webdevicons#refresh()
  endif
]])
