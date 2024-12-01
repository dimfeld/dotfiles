local M = {}

M.my_vscode = vim.api.nvim_create_augroup("MyVSCode", {})

vim.filetype.add({
  pattern = {
    [".*%.ipynb.*"] = "python",
    -- uses lua pattern matching
    -- rathen than naive matching
  },
})

local function map_vscode(mode, binding, cmd)
  vim.keymap.set(mode, binding, function()
    require("vscode").action(cmd)
  end, { silent = true })
end

map_vscode("n", "K", "editor.action.showHover")
map_vscode("n", "[g", "editor.action.marker.prev")
map_vscode("n", "]g", "editor.action.marker.next")
map_vscode("n", "<leader>dt", "editor.action.peekTypeDefinition")
map_vscode("n", "<leader>dd", "editor.action.revealDefinition")
map_vscode("n", "<leader>dr", "editor.action.goToReferences")
map_vscode({ "n", "i" }, "<C-h>", "workbench.action.focusLeftGroupWithoutWrap")
map_vscode({ "n", "i" }, "<C-l>", "workbench.action.focusRightGroupWithoutWrap")
map_vscode({ "n", "i" }, "<C-j>", "workbench.action.focusBelowGroupWithoutWrap")
map_vscode({ "n", "i" }, "<C-k>", "workbench.action.focusAboveGroupWithoutWrap")
-- map_vscode("n", "<leader>ac", "editor.action.quickFix")
map_vscode({ "n", "v", "x" }, "<leader>c", "editor.action.commentLine")
map_vscode("n", "<leader>rn", "editor.action.rename")
map_vscode("n", "<leader>t", "workbench.action.quickOpen")
map_vscode("n", "<leader>g", "periscope.search")
map_vscode("n", "<leader>ws", "workbench.action.showAllSymbols")
map_vscode("n", "<leader>ds", "workbench.action.gotoSymbol")
map_vscode("n", "[c-\\]", "workbench.action.terminal.toggleTerminal")
map_vscode("n", "\\", "workbench.action.showAllEditorsByMostRecentlyUsed")
map_vscode({ "n", "v" }, "<leader>k", "editor.action.showCommands")
map_vscode("n", "u", "undo")
map_vscode("n", "<c-r>", "redo")
map_vscode("i", "<leader>c", "acceptSelectedSuggestion")
map_vscode("n", "<leader>ac", "editor.action.quickFix")
vim.keymap.set("n", "<leader>af", vim.lsp.buf.code_action, { silent = true })
-- Remove default mapping for c-] to avoid conflict with autocomplete
vim.keymap.set("n", "<c-]>", function() end, { silent = true })

-- keymap("n", "<Leader>xr", notify("references-view.findReferences"), { silent = true }) -- language references
-- keymap("n", "<Leader>xd", notify("workbench.actions.view.problems"), { silent = true }) -- language diagnostics
-- keymap("n", "gr", notify("editor.action.goToReferences"), { silent = true })
-- keymap("n", "<Leader>rn", notify("editor.action.rename"), { silent = true })
-- keymap("n", "<Leader>fm", notify("editor.action.formatDocument"), { silent = true })
-- keymap("n", "<Leader>ca", notify("editor.action.refactor"), { silent = true }) -- language code actions
--
-- keymap("n", "<Leader>rg", notify("workbench.action.findInFiles"), { silent = true }) -- use ripgrep to search files
-- keymap("n", "<Leader>ts", notify("workbench.action.toggleSidebarVisibility"), { silent = true })
-- keymap("n", "<Leader>th", notify("workbench.action.toggleAuxiliaryBar"), { silent = true }) -- toggle docview (help page)
-- keymap("n", "<Leader>tp", notify("workbench.action.togglePanel"), { silent = true })
-- keymap("n", "<Leader>fc", notify("workbench.action.showCommands"), { silent = true }) -- find commands
-- keymap("n", "<Leader>ff", notify("workbench.action.quickOpen"), { silent = true }) -- find files
-- keymap("n", "<Leader>tw", notify("workbench.action.terminal.toggleTerminal"), { silent = true }) -- terminal window
--
-- keymap("v", "<Leader>fm", v_notify("editor.action.formatSelection"), { silent = true })
-- keymap("v", "<Leader>ca", v_notify("editor.action.refactor"), { silent = true })
-- keymap("v", "<Leader>fc", v_notify("workbench.action.showCommands"), { silent = true })

return M
