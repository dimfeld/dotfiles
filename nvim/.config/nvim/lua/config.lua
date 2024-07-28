local git_helpers = require("lib.git")
local window_helpers = require("lib.window")
local path = require("plenary.path")
local format_util = require("formatter.util")

vim.o.mousemodel = "extend"

function reload_nvim_conf()
  for name, _ in pairs(package.loaded) do
    if
      name:match("^core")
      or name:match("^lsp")
      or name:match("^plugins")
      or name:match("^config")
      or name:match("^commands")
      or name:match("^lib")
      or name:match("^llm")
    then
      package.loaded[name] = nil
    end
  end

  vim.cmd("source" .. vim.env.MYVIMRC)
  vim.notify("Nvim configuration reloaded!", vim.log.levels.INFO)
end

vim.api.nvim_create_user_command("ReloadInit", reload_nvim_conf, {})
vim.api.nvim_create_user_command("EditInit", "e ~/.config/nvim/lua/config.lua", {})

vim.o.undofile = true
vim.o.undolevels = 3000
vim.o.undoreload = 10000
vim.o.backupdir = vim.fn.expand("~/tmp,.,~/")
vim.o.directory = vim.fn.expand("~/tmp,.,~/") -- Where to keep swap files
vim.o.backup = true
vim.o.swapfile = false
vim.o.scrolloff = 8

---- code language configs

local auGroup = vim.api.nvim_create_augroup("CodeLangs", {})
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  group = auGroup,
  pattern = "*.pcss",
  callback = function()
    vim.bo.syntax = "scss"
  end,
})

-- Insert spaces when TAB is pressed.
vim.o.expandtab = true

-- Indentation amount for < and > commands.
vim.o.shiftwidth = 2
vim.o.softtabstop = 2
vim.o.tabstop = 4

local auGroup = vim.api.nvim_create_augroup("TabStops", {})

vim.api.nvim_create_autocmd("FileType", {
  group = auGroup,
  pattern = "svelte",
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.formatoptions:append("ro")
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = auGroup,
  pattern = "rust",
  callback = function()
    vim.opt_local.shiftwidth = 4
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = auGroup,
  pattern = "go",
  callback = function()
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
  end,
})

---- Prose Filetype configs

-- # Markdown
vim.g["vim_markdown_conceal"] = 0
vim.g["tex_conceal"] = ""
vim.g["vim_markdown_math"] = 1
vim.g["vim_markdown_frontmatter"] = 1
vim.g["vim_markdown_strikethrough"] = 1
vim.g["vim_markdown_no_extensions_in_markdown"] = 1
vim.g["vim_markdown_edit_url_in"] = "vsplit"
vim.g["vim_markdown_folding_style_pythonic"] = 1
vim.g["vim_markdown_folding_level"] = 6

local markdownGroup = vim.api.nvim_create_augroup("markdown", {})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = markdownGroup,
  pattern = "*.md",
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.formatoptions:append("t")
  end,
})

local asciidocGroup = vim.api.nvim_create_augroup("AsciiDoc", {})
vim.api.nvim_create_autocmd("FileType", {
  group = asciidocGroup,
  pattern = "asciidoc",
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.shiftwidth = 2
    vim.opt_local.wrap = true
    vim.opt_local.lbr = true
    vim.opt_local.foldlevel = 99
    vim.keymap.set("n", "<Down>", "gj", { buffer = true, desc = "Next line with wrapping" })
    vim.keymap.set("n", "<Up>", "gk", { buffer = true, desc = "Previous line with wrapping" })
  end,
})

-- Don't give completion messages like 'match 1 of 2' or 'The only match'
vim.opt.shortmess:append("cs")

---- AI Assistants

vim.keymap.set("n", "<leader>lf", function()
  require("commands.llm").fill_holes()
end, {
  desc = "LLM fill-in",
})

vim.keymap.set({ "n", "v" }, "<leader>la", function()
  vim.ui.input({
    prompt = "What operation should be done?",
  }, function(operation)
    if not operation then
      return
    end

    require("commands.llm").fill_holes({
      operation = operation,
    })
  end)
end, {
  desc = "LLM ask",
})

---- Editor Commands

-- Map ; to : in case I don't press Shift quickly enough
vim.keymap.set("n", ";", ":", {})
-- # Buffer Navigation --

-- Hides buffers instead of closing them
vim.o.hidden = true

-- Prevent diagonal scroll in Kitty
vim.keymap.set({ "i", "n", "v", "t" }, "<ScrollWheelLeft>", "<Nop>", {})
vim.keymap.set({ "i", "n", "v", "t" }, "<ScrollWheelRight>", "<Nop>", {})
vim.keymap.set({ "i", "n", "v", "t" }, "<S-ScrollWheelUp>", "<ScrollWheelRight>", {})
vim.keymap.set({ "i", "n", "v", "t" }, "<S-ScrollWheelDown>", "<ScrollWheelLeft>", {})

-- Quick move cursor from insert mode
-- These map to cmd/option + arrow keys
vim.keymap.set("i", "<C-a>", "<C-o>^", {})
vim.keymap.set("i", "<C-e>", "<C-o>$", {})
vim.keymap.set("n", "<C-a>", "^", {})
vim.keymap.set("n", "<C-e>", "$", {})
vim.keymap.set("i", "<D-Left>", "<C-o>^", {})
vim.keymap.set("i", "<D-Right>", "<C-o>$", {})
vim.keymap.set("n", "<D-Left>", "^", {})
vim.keymap.set("n", "<D-Right>", "$", {})

vim.keymap.set("i", "<C-Left>", "<C-o>^", {})
vim.keymap.set("i", "<C-Right>", "<C-o>$", {})
vim.keymap.set("n", "<C-Left>", "^", {})
vim.keymap.set("n", "<C-Right>", "$", {})

vim.keymap.set("i", "<M-h>", "<C-o>b", {})
vim.keymap.set("i", "<M-l>", "<C-o>w", {})
vim.keymap.set("n", "<M-h>", "b", {})
vim.keymap.set("n", "<M-l>", "w", {})

vim.keymap.set("i", "<M-g>", "<C-o>^", {})
vim.keymap.set("i", "<M-;>", "<C-o>$", {})
vim.keymap.set("n", "<M-g>", "^", {})
vim.keymap.set("n", "<M-;>", "$", {})

vim.keymap.set("i", "<M-Left>", "<C-o>b", {})
vim.keymap.set("i", "<M-Right>", "<C-o>w", {})
vim.keymap.set("n", "<M-Left>", "b", {})
vim.keymap.set("n", "<M-Right>", "w", {})

vim.keymap.set("i", "<M-b>", "<C-o>b", {})
vim.keymap.set("i", "<M-f>", "<C-o>w", {})
vim.keymap.set("n", "<M-b>", "b", {})
vim.keymap.set("n", "<M-f>", "w", {})

-- Scroll window without moving cursor
vim.keymap.set("n", "z<Up>", "10<c-e>", {})
vim.keymap.set("n", "z<Down>", "10<c-y>", {})

-- Quick window switching
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")
vim.keymap.set("n", "<leader>p", ":b#<CR>", { silent = true })

-- Command line
vim.keymap.set("c", "<D-Left>", "<Home>", {})
vim.keymap.set("c", "<D-Right>", "<End>", {})
vim.keymap.set("c", "<M-Left>", "<S-Left>", {})
vim.keymap.set("c", "<M-Right>", "<S-Right>", {})

-- # Comments
vim.o.comments = "s1:/*,mb:*,ex:*/,://,b:#,:%,:XCOMM,fb:-"
vim.keymap.set("n", "<leader>c", "gcc", { remap = true })
vim.keymap.set("v", "<leader>c", "gc", { remap = true })
-- vim.keymap.set("n", "gcu", "gcgc", { remap = true })
require("Comment").setup({
  pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
})

-- vim-better-whitespace
-- Strip whitespace from end of line throughout entire file
vim.keymap.set("n", "<leader>wt", ":StripWhitespace<CR>", { silent = true })

-- # Registers --

-- Delete current visual selection and dump in black hole register before pasting
-- Used when you want to paste over something without it getting copied to
-- Vim's default buffer
vim.keymap.set("v", "<leader>p", '"_dP', {})

-- Delete current selection without yanking
vim.keymap.set("v", "<leader>d", '"_d', {})

-- Copy last yanked/deleted text into register a.
-- For when you want to save into a register but forgot when you ran delete.
vim.keymap.set("n", "<leader>y", function()
  local lastYanked = vim.fn.getreg('"')
  vim.fn.setreg("a", lastYanked)
end, { silent = true })

-- Try to copy into local native clipboard when in an SSH session
vim.keymap.set("x", "<leader>y", vim.cmd.OSCYank, { silent = true })

-- # Macros

-- Quick run macro @q
vim.keymap.set("n", "<Tab>", "@q", {})
-- Clear macro q at startup to prevent old ones from running by mistake
vim.fn.setreg("q", "")

-- When a visual range is selected, run a macro over each line in the range
vim.keymap.set("x", "@", function()
  local macro_key = vim.fn.nr2char(vim.fn.getchar())
  print("@" .. macro_key)
  return ":normal @" .. macro_key .. "<CR>"
end, { expr = true, silent = true })

-- # File System

-- Set CWD to directory of current file
vim.api.nvim_create_user_command("Cdme", "cd %:p:h", {})
-- Set CWD to repository root
vim.api.nvim_create_user_command("CdRepo", function()
  vim.cmd("cd " .. git_helpers.git_repo_toplevel())
end, {})

-- Reload changed files automatically
vim.o.autoread = true

-- Preload :e command with directory of current buffer.
vim.keymap.set("n", "<leader>e", ":e %:h/", {})

-- # Search

vim.o.incsearch = true
-- Ignore case in search unless the search has an uppercase letter
vim.o.ignorecase = true
vim.o.smartcase = true

-- Repeat last replace across selected lines
vim.keymap.set("x", "&", ":'<,'>&&<CR>", { silent = true })
-- Clear search highlighting
vim.keymap.set({ "n", "x" }, "<leader>/", vim.cmd.nohlsearch, { silent = true })

-- Repeat last command over visual selection
vim.keymap.set("x", "<Leader>.", "q:<UP>I'<,'><Esc>$", {})

---- Quickfix Buffer interaction

function qf_keymaps()
  -- o key opens the line under the quickfix and returns focus to quickfix
  vim.api.nvim_buf_set_keymap(0, "n", "o", "<CR><C-w>p", { silent = true, noremap = true })
  -- Open the selected line in the qucikfix buffer, and close the quickfix pane.
  vim.api.nvim_buf_set_keymap(0, "n", "O", "<CR>:cclose<CR>", { silent = true, noremap = true })
end

local augroup = vim.api.nvim_create_augroup("QfKeymaps", {})

vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = "qf",
  callback = qf_keymaps,
})

---- Code formatting

local auGroup = vim.api.nvim_create_augroup("Autoformat", {})
vim.api.nvim_create_autocmd("BufWritePost", {
  group = auGroup,
  pattern = "*",
  callback = function()
    vim.cmd.FormatWrite()
  end,
})

---- Telescope
require("config.telescope_commandbar").setup()

---- Theme
require("config.theme")

require("config.terminal")

---- Other Commands
require("commands.dash")
require("commands.git")
