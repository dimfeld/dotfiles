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

---- code language configs

vim.g.svelte_preprocessor_tags = {
  { name = "postcss", tag = "style", as = "scss" },
}

vim.g.svelte_preprocessors = { "typescript", "postcss", "scss" }

vim.g.vim_svelte_plugin_use_typescript = 1
vim.g.vim_svelte_plugin_use_sass = 1

local auGroup = vim.api.nvim_create_augroup("CodeLangs", {})
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  group = auGroup,
  pattern = "*.pcss",
  callback = function()
    vim.bo.syntax = "scss"
  end,
})

require("nvim-treesitter.configs").setup({
  ensure_installed = {
    "svelte",
    "typescript",
  },
  context_commentstring = {
    enable = true,
    enable_autocmd = false,
    commentary_integration = {
      Commentary = false,
      CommentaryLine = false,
    },
  },
  matchup = {
    enable = true,
  },
  highlight = {
    enable = true,
    -- disable = { "rust", "javascript", "javascript.jsx" },
  },
  indent = {
    enable = true,
  },
  autopairs = { enable = true },
})

-- Enable treesitter-based folding
vim.o.foldmethod = "expr"
vim.o.foldexpr = "nvim_treesitter#foldexpr()"
vim.o.foldenable = false

local get_option = vim.filetype.get_option
vim.filetype.get_option = function(filetype, option)
  return option == "commentstring" and require("ts_context_commentstring.internal").calculate_commentstring()
    or get_option(filetype, option)
end

-- Autopairs
local npairs = require("nvim-autopairs")

function pum_visible()
  return vim.fn["coc#pum#visible"]() == 1
end

npairs.setup({
  check_ts = true,
  ignored_next_char = "[%w%.\"']", -- will ignore alphanumeric and `.` symbol
})

local Rule = require("nvim-autopairs.rule")
local cond = require("nvim-autopairs.conds")

-- Only add closing bracket if <CR> is hit right after the opening bracket
-- npairs.remove_rule('{')
-- npairs.add_rules({
--   Rule('{', '}'):end_wise(function(opts)
--     local lastChar = string.sub(vim.trim(opts.line), -1)
--     return lastChar == '{' or lastChar == ')'
--   end)
-- })

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

vim.api.nvim_create_autocmd("FileType", {
  group = markdownGroup,
  pattern = "markdown",
  callback = function()
    require("section-wordcount").wordcounter({})
  end,
})

vim.g["asciidoctor_folding"] = 1
vim.g["asciidoctor_fenced_languages"] = {
  "sql",
  "svelte",
  "rust",
  "bash",
}

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
    vim.keymap.set("n", "<Down>", "gj", { buffer = true })
    vim.keymap.set("n", "<Up>", "gk", { buffer = true })
    require("section-wordcount").wordcounter({
      header_char = "=",
    })
  end,
})

-- # Completion --

-- Tab and S-Tab navigate completion popup, if it's open
vim.keymap.set("i", "<TAB>", function()
  if pum_visible() then
    return vim.fn["coc#pum#next"](1)
  else
    return "<TAB>"
  end
end, { expr = true, silent = true })

vim.keymap.set("i", "<S-TAB>", function()
  if pum_visible() then
    return vim.fn["coc#pum#prev"](1)
  else
    return "<S-TAB>"
  end
end, { expr = true, silent = true })

-- Cancel confirmation when arrow key is pressed
function close_pum_when_pressed(key)
  vim.keymap.set("i", key, function()
    if pum_visible() then
      vim.fn["coc#pum#stop"]()
    end

    return key
  end, { expr = true })
end

-- Close preview window when completion is done.
local auGroup = vim.api.nvim_create_augroup("completion", {})
vim.api.nvim_create_autocmd("CompleteDone", {
  group = auGroup,
  pattern = "*",
  callback = function()
    if not pum_visible() and vim.fn["getcmdwintype"]() == "" then
      vim.cmd("pclose")
    end
  end,
})

close_pum_when_pressed("<up>")
close_pum_when_pressed("<down>")
close_pum_when_pressed("<left>")
close_pum_when_pressed("<right>")

-- Open completion popup
vim.keymap.set("i", "<c-space>", function()
  vim.fn["coc#start"]()
end, { silent = true })

-- Allow triggering code action, such as adding import, from completion window
vim.keymap.set("i", "<leader>c", function()
  if pum_visible() then
    return vim.fn["coc#pum#confirm"]()
  else
    return "<leader>c"
  end
end, { silent = true, expr = true, desc = "Trigger code action" })

-- Don't give completion messages like 'match 1 of 2' or 'The only match'
vim.opt.shortmess:append("c")

---- AI Assistants

-- local completion_assistant = "copilot"
local completion_assistant = "codeium"
-- local completion_assistant = "supermaven"

vim.g.codeium_enabled = completion_assistant == "codeium"

local disable_copilot_group = vim.api.nvim_create_augroup("DisableCopilot", {})
if completion_assistant == "codeium" then
  vim.api.nvim_create_autocmd("BufEnter", {
    group = disable_copilot_group,
    pattern = "*",
    callback = function()
      vim.b.copilot_enabled = false
    end,
  })
end

vim.g.codeium_no_map_tab = true
vim.g.copilot_no_tab_map = true

if completion_assistant == "codeium" or completion_assistant == "copilot" then
  local acceptCmd = completion_assistant == "codeium" and "codeium#Accept()" or 'copilot#Accept("")'
  local acceptKeyOpts = { silent = true, expr = true, script = true, replace_keycodes = false }

  vim.keymap.set("i", "<C-J>", acceptCmd, acceptKeyOpts)
  vim.keymap.set("i", "<C-]>", acceptCmd, acceptKeyOpts)

  vim.g.copilot_filetypes = {
    markdown = true,
  }
elseif completion_assistant == "supermaven" then
  require("supermaven-nvim").setup({
    keymaps = {
      accept_suggestion = "<C-]>",
      clear_suggestion = "<C-J>",
      accept_word = "<M-]>",
    },
    color = {
      suggestion_color = "#eeaaaa",
      cterm = 10,
    },
  })
end

require("oatmeal").setup({
  backend = "ollama",
  model = "deepseek-coder-v2:16b-lite-instruct-fp16",
})

require("aider").setup({
  auto_manage_context = true,
  default_keybindings = false,
})

vim.keymap.set("n", "<leader>m", function()
  require("commands.llm").fill_holes()
end, {
  desc = "LLM fill-in",
})

---- Debugging

local dap, dapui = require("dap"), require("dapui")
dapui.setup()

dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end

-- point dap to the installed cpptools, if you don't use mason, you'll need to change `cpptools_path`
--local cpptools_path = vim.fn.stdpath("data").."/mason/packages/cpptools/extension/debugAdapters/bin/OpenDebugAD7"
--dap.adapters.cppdbg = {
--    id = 'cppdbg',
--    type = 'executable',
--    command = cpptools_path,
--}

vim.keymap.set("n", "<F1>", dap.terminate)
vim.keymap.set("n", "<F6>", dap.toggle_breakpoint)
vim.keymap.set("n", "<F7>", dap.continue)
vim.keymap.set("n", "<F8>", dap.step_over)
vim.keymap.set("n", "<F9>", dap.step_out)
vim.keymap.set("n", "<F10>", dap.step_into)
vim.keymap.set("n", "<F11>", dap.pause)
vim.keymap.set("n", "<F56>", dap.down) -- <A-F8>
vim.keymap.set("n", "<F57>", dap.up) -- <A-F9>

-- local rr_dap = require("nvim-dap-rr")
-- rr_dap.setup({
--     mappings = {
--         -- you will probably want to change these defaults to that they match
--         -- your usual debugger mappings
--         continue = "<F7>",
--         step_over = "<F8>",
--         step_out = "<F9>",
--         step_into = "<F10>",
--         reverse_continue = "<F19>", -- <S-F7>
--         reverse_step_over = "<F20>", -- <S-F8>
--         reverse_step_out = "<F21>", -- <S-F9>
--         reverse_step_into = "<F22>", -- <S-F10>
--         -- instruction level stepping
--         step_over_i = "<F32>", -- <C-F8>
--         step_out_i = "<F33>", -- <C-F8>
--         step_into_i = "<F34>", -- <C-F8>
--         reverse_step_over_i = "<F44>", -- <SC-F8>
--         reverse_step_out_i = "<F45>", -- <SC-F9>
--         reverse_step_into_i = "<F46>", -- <SC-F10>
--     }
-- })
-- dap.configurations.rust = { rr_dap.get_rust_config() }
-- dap.configurations.cpp = { rr_dap.get_config() }

---- Editor Commands

-- Dial does number incrementing and decrementing
local dial = require("dial.map")
vim.keymap.set("n", "<M-i>", dial.inc_normal(), { desc = "Increment number" })
vim.keymap.set("n", "<M-d>", dial.dec_normal(), { desc = "Decrement number" })
vim.keymap.set("n", "g<M-i>", dial.inc_gnormal(), { desc = "Stacking increment" })
vim.keymap.set("n", "g<M-d>", dial.dec_gnormal(), { desc = "Stacking decrement" })
vim.keymap.set("v", "<M-i>", dial.inc_visual(), { desc = "Increment number" })
vim.keymap.set("v", "<M-d>", dial.dec_visual(), { desc = "Decrement number" })
vim.keymap.set("v", "g<M-i>", dial.inc_gvisual(), { desc = "Stacking increment" })
vim.keymap.set("v", "g<M-d>", dial.dec_gvisual(), { desc = "Stacking decrement" })

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

-- Leap for quick navigation through the buffer
require("leap")
vim.keymap.set({ "n", "x", "o" }, "s", "<Plug>(leap-forward-to)", { noremap = false })
vim.keymap.set({ "n", "x", "o" }, "S", "<Plug>(leap-backward-to)", { noremap = false })
vim.keymap.set({ "x", "o" }, "x", "<Plug>(leap-forward-till)", { noremap = false })
vim.keymap.set({ "x", "o" }, "X", "<Plug>(leap-backward-till)", { noremap = false })
vim.keymap.set({ "n", "x", "o" }, "gs", "<Plug>(leap-from-window)", { noremap = false })

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

-- Editor Commands for LSP/CoC
vim.keymap.set("n", "<leader>dd", "<Plug>(coc-definition)", { silent = true })
vim.keymap.set("n", "<leader>dj", "<Plug>(coc-implementation)", { silent = true })
vim.keymap.set("n", "<leader>dg", function()
  vim.cmd("call CocActionAsync('diagnosticInfo', 'float')")
end, { silent = true })
vim.keymap.set("n", "<leader>rn", "<Plug>(coc-rename)", { silent = true })
vim.keymap.set("n", "[G", "<Plug>(coc-diagnostic-prev)", { silent = true })
vim.keymap.set("n", "]G", "<Plug>(coc-diagnostic-next)", { silent = true })
vim.keymap.set("n", "[g", "<Plug>(coc-diagnostic-prev-error)", { silent = true })
vim.keymap.set("n", "]g", "<Plug>(coc-diagnostic-next-error)", { silent = true })

vim.keymap.set("n", "<leader>al", "<Plug>(coc-codeaction-line)", { silent = true })
vim.keymap.set("n", "<leader>ac", "<Plug>(coc-codeaction-cursor)", { silent = true })
vim.keymap.set("n", "<leader>af", "<Plug>(coc-codeaction)", { silent = true })

vim.g["coc_global_extensions"] = {
  "coc-css",
  "coc-eslint",
  "coc-git",
  "coc-go",
  "coc-html",
  "coc-json",
  "coc-pyright",
  "coc-rust-analyzer",
  "coc-svelte",
  "coc-tsserver",
  "coc-xml",
  "@yaegassy/coc-tailwindcss3",
}

-- Documentation with K and c-K

function toggle_documentation()
  if vim.call("coc#float#has_float") > 0 then
    vim.call("coc#float#close_all")
  else
    show_documentation()
  end
end

function toggle_signature_help()
  if vim.call("coc#float#has_float") > 0 then
    vim.call("coc#float#close_all")
  else
    vim.call("CocActionAsync", "showSignatureHelp", hover_callback)
  end
end

function hover_callback(e, r)
  if r == false then
    vim.call("CocActionAsync", "doHover")
  end
end

function show_documentation()
  local filetype = vim.bo.filetype
  if filetype == "vim" or filetype == "help" then
    vim.cmd("h " .. vim.fn.expand("<cword>"))
  elseif vim.call("coc#rpc#ready") then
    vim.call("CocActionAsync", "doHover")
  else
    vim.cmd("!" .. vim.bo.keywordprg .. " " .. vim.fn.expand("<cword>"))
  end
end

vim.keymap.set("n", "K", toggle_documentation, {})
vim.keymap.set("i", "<C-K>", toggle_signature_help, {})

local augroup = vim.api.nvim_create_augroup("RepositionFloat", {})
vim.api.nvim_create_autocmd("User", {
  -- This doesn't work right yet.
  -- The scrollbar doesn't relocate with the window
  -- When we jump to the next diagnostic, the popup relocates after this code is called.
  group = augroup,
  pattern = "CocOpenFloat",
  callback = function(ev)
    local float_win = vim.g.coc_last_float_win
    if not window_helpers.is_coc_diagnostic_window(float_win) then
      -- Don't reposition for normal popups, just for things like diagnostic window
      return
    end

    local current_win = vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_win_get_buf(float_win)
    local win_height = vim.api.nvim_win_get_height(current_win)
    local win_width = vim.api.nvim_win_get_width(current_win)
    local float_config = vim.api.nvim_win_get_config(float_win)
    local new_col = math.floor((win_width - float_config.width))
    local new_row = win_height - float_config.height - 1

    -- Not working yet, it overrides a lot of the existing window config that I
    -- don't know how to get yet.
    -- vim.fn["coc#float#create_float_win"](float_win, buf, {
    --   relative = "editor",
    --   row = new_row,
    --   width = float_config.width,
    --   height = float_config.height,
    --   col = new_col,
    -- })

    -- This also doesn't work yet, because it doesn't move the scrollbar and related windows along with the main
    -- window. Ideally we could get the original config object and reuse it, just changing the values we want, but I don't think there's
    -- an easy way to do that.
    -- vim.api.nvim_win_set_config(float_win, {
    --   relative = "win",
    --   win = current_win,
    --   row = win_height,
    --   col = 0,
    --   anchor = "SW",
    -- })
  end,
})

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

vim.env.PRETTIERD_LOCAL_PRETTIER_ONLY = "true"

local prettier_config_files = {
  ".prettierrc",
  ".prettierrc.js",
  ".prettierrc.json",
  "prettier.config.js",
  "prettier.config.cjs",
}

local prettierd = function()
  local current_path = format_util.get_current_buffer_file_path()
  local current_dir = vim.fs.dirname(current_path)
  local found_config = vim.fs.find(prettier_config_files, {
    path = current_dir,
    upward = true,
    type = "file",
    limit = 1,
  })

  local _, found = next(found_config)
  -- print(vim.inspect(found))
  if found == nil then
    return nil
  end

  local config_dirname = vim.fs.dirname(found)

  return {
    exe = "prettierd",
    args = { format_util.escape_path(current_path) },
    cwd = config_dirname,
    stdin = true,
  }
end

local black = function()
  return {
    exe = "python3",
    args = { "-m", "black", "-q", "-" },
    stdin = true,
  }
end

local ruff = function()
  local current_path = format_util.get_current_buffer_file_path()
  return {
    exe = "python3",
    args = { "-m", "ruff", "format", "--stdin-filename", format_util.escape_path(current_path), "-s" },
    stdin = true,
  }
end

-- Stylua Lua formatter
function stylua()
  return {
    exe = "stylua",
    args = {
      "--indent-type",
      "Spaces",
      "--indent-width",
      "2",
      "--search-parent-directories",
      "--stdin-filepath",
      format_util.escape_path(format_util.get_current_buffer_file_path()),
      "--",
      "-",
    },
    stdin = true,
  }
end

-- Sleek SQL formatter
function sleek()
  local current_path = format_util.get_current_buffer_file_path()
  return {
    exe = "sleek",
    args = { "-i", "2" },
    stdin = true,
  }
end

-- pg_format
function pgformat()
  local current_path = format_util.get_current_buffer_file_path()
  if current_path:find(".sql.tera") then
    return nil
  end

  return {
    exe = "pg_format --inplace  -",
    stdin = true,
  }
end

-- Format .sql.liquid files
function liquid_sql()
  local current_path = format_util.get_current_buffer_file_path()
  if current_path:find(".sql.liquid") == nil then
    return nil
  end

  -- turn this off for now
  if true then
    return nil
  end

  return pgformat()
end

require("formatter").setup({
  logging = true,
  -- log_level = vim.log.levels.TRACE,
  filetype = {
    html = { prettierd },
    css = { prettierd },
    less = { prettierd },
    pcss = { prettierd },
    postcss = { prettierd },
    javascript = { prettierd },
    json = { prettierd },
    typescript = { prettierd },
    svelte = { prettierd },
    python = { ruff },
    lua = { stylua },
    sql = { pgformat },
    liquid = { liquid_sql },
  },
})

local auGroup = vim.api.nvim_create_augroup("Autoformat", {})
vim.api.nvim_create_autocmd("BufWritePost", {
  group = auGroup,
  pattern = "*",
  callback = function()
    vim.cmd.FormatWrite()
  end,
})

vim.api.nvim_create_user_command("Format", function()
  vim.fn.CocAction("runCommand", "editor.action.formatDocument")
end, {})

---- Telescope
require("config.telescope")
require("config.telescope_commandbar")

---- Theme
require("config.status_line")
require("config.theme")

require("config.terminal")

---- Other Commands
require("commands.dash")
require("commands.git")
