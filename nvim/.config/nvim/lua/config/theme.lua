vim.o.number = true
vim.o.termguicolors = true
vim.o.guifont = "Inconsolata:h14"

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

-- Popup menu height (completion menu, etc.)
vim.o.pumheight = 20

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
    if vim.bo.filetype ~= "csv" then
      vim.cmd("syntax sync minlines=1000")
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = highlightGroup,
  callback = function()
    local ft = vim.bo.filetype
    local lang = vim.treesitter.language.get_lang(ft)
    if lang then
      local ts = vim.treesitter.language.add(lang)
      if ts then
        vim.treesitter.start()
      end
    end
  end,
})

-- Customize colors

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
