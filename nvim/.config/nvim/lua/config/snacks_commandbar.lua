local M = {}

local window = require("lib.window")
local builtin = require("telescope.builtin")
local SnacksPicker = require("snacks.picker")

--- @class ActionOpts
--- @field cursor CursorRange

--- @class CommandBarAction
--- @field name string
--- @field category string
--- @field filetype? string | string[]
--- @field action fun(opts: ActionOpts)

-- Information about the current cursor position, useful when running a command that needs to access the visual
-- selection since opening the picker will lose it.
--- @type CursorRange
M.current_cursor = nil

--- @param prefix string
local runLspPrefixAction = function(prefix)
  for _, client in ipairs(vim.lsp.get_clients()) do
    local ac1 = (
      client.server_capabilities
      and client.server_capabilities.codeActionProvider
      and type(client.server_capabilities.codeActionProvider) == "table"
      and client.server_capabilities.codeActionProvider.codeActionKinds
    ) or {}

    local ac2 = (
      client.capabilities
      and client.capabilities.textDocument
      and client.capabilities.textDocument.codeAction
      and client.capabilities.textDocument.codeAction.codeActionLiteralSupport
      and client.capabilities.textDocument.codeAction.codeActionLiteralSupport.codeActionKind
      and client.capabilities.textDocument.codeAction.codeActionLiteralSupport.codeActionKind.valueSet
    ) or {}

    local ac = vim.list_extend(vim.deepcopy(ac1), ac2)

    for _, action in ipairs(ac) do
      if vim.startswith(action, prefix) then
        vim.lsp.buf.code_action({
          context = {
            only = { action },
            diagnostics = {},
          },
          apply = true,
        })

        return
      end
    end
  end
end

--- @type CommandBarAction[]
M.commands = {
  {
    name = "Organize imports",
    category = "LS",
    filetype = "typescript",
    action = function()
      runLspPrefixAction("source.organizeImports")
    end,
  },
  {
    name = "Remove Unused imports",
    category = "LS",
    filetype = "typescript",
    action = function()
      runLspPrefixAction("source.removeUnusedImports")
    end,
  },

  {
    name = "Add Missing imports",
    category = "LS",
    filetype = "typescript",
    action = function()
      runLspPrefixAction("source.addMissingImports")
    end,
  },
  {
    name = "Rename symbol",
    category = "LS",
    action = function()
      vim.lsp.buf.rename()
    end,
  },
  {
    name = "Go to Symbol Definition",
    category = "LS",
    action = function()
      vim.lsp.buf.definition()
    end,
  },
  {
    name = "Restart Svelte LS",
    category = "LS",
    action = function()
      vim.cmd("LspRestart svelte")
    end,
  },
  {
    name = "Restart LS",
    category = "LS",
    action = function()
      vim.cmd("LspRestart")
    end,
  },
  {
    name = "Restart Typescript LS",
    category = "LS",
    action = function()
      vim.cmd("LspRestart ts_ls")
    end,
  },

  {
    name = "Copy Buffer Path to Clipboard",
    category = "Clipboard",
    action = function()
      local path = require("lib.window").get_repo_buffer_path()
      vim.fn.setreg("+", path)
    end,
  },

  {
    name = "Unescape JSON quotes",
    category = "JSON",
    action = function()
      vim.cmd([[s/\\"/"/g]])
    end,
  },

  {
    name = "Prefix with 'pub'",
    category = "Editing",
    filetype = "rust",
    action = function(opts)
      local saved_hl = vim.fn.getreg("/")
      local cmd = opts.cursor.start.line .. "," .. opts.cursor.stop.line .. [[s/\S/pub &/e]]
      vim.cmd(cmd)
      vim.fn.setreg("/", saved_hl)
    end,
  },
  {
    name = "View Undo Tree",
    category = "Editing",
    action = function()
      SnacksPicker.undo()
    end,
  },

  {
    name = "Resync Syntax",
    category = "Buffer",
    action = function()
      vim.cmd("syntax sync fromstart")
    end,
  },

  { name = "Quickfix Search", category = "Quickfix", action = builtin.quickfix },
  { name = "Quickfix History", category = "Quickfix", action = builtin.quickfixhistory },

  {
    name = "Yank to Clipboard",
    category = "Clipboard",
    action = function(opts)
      vim.cmd(M.build_range_prefix(opts.cursor) .. "y*")
    end,
  },
  {
    name = "Delete to Blackhole",
    category = "Clipboard",
    action = function(opts)
      vim.cmd(M.build_range_prefix(opts.cursor) .. "d_")
    end,
  },

  {
    name = "Nodes Join",
    category = "Editing",
    action = function()
      require("treesj").join()
    end,
  },

  {
    name = "Nodes Split",
    category = "Editing",
    action = function()
      require("treesj").split()
    end,
  },

  {
    name = "Nodes Toggle",
    category = "Editing",
    action = function()
      require("treesj").toggle()
    end,
  },
}

--- @param commands CommandBarAction[]
M.add_commands = function(commands)
  for _, command in ipairs(commands) do
    table.insert(M.commands, command)
  end
end

--- @param command_ft string | string[] | nil
--- @param filetype string
--- @return boolean
local function matches_filetype(command_ft, filetype)
  if command_ft == nil then
    return true
  end

  if type(command_ft) == "string" then
    return command_ft == filetype or (filetype == "svelte" and command_ft == "typescript")
  end

  for _, ft in ipairs(command_ft) do
    if matches_filetype(ft, filetype) then
      return true
    end
  end

  return false
end

--- @param command_id string
--- @param filetype string
--- @return boolean
local function matches_lsp_command(command_id, filetype)
  if vim.startswith(command_id, "rust-analyzer.") == 1 then
    return filetype == "rust"
  elseif vim.startswith(command_id, "pyright.") then
    return filetype == "python"
  elseif vim.startswith(command_id, "python.") then
    return filetype == "python"
  elseif vim.startswith(command_id, "svelte.") then
    return filetype == "svelte"
  elseif vim.startswith(command_id, "_typescript.") then
    return false
  elseif vim.startswith(command_id, "typescript.") or vim.startswith(command_id, "javascript.") then
    if filetype ~= "typescript" and filetype ~= "javascript" and filetype ~= "svelte" then
      return false
    end

    if
      ((filetype == "typescript" or filetype == "svelte") and vim.startswith(command_id, "javascript"))
      or (filetype == "javascript" and vim.startswith(command_id, "typescript"))
    then
      return false
    end
  end

  return true
end

local function show_common_commands_picker(opts)
  M.current_cursor = window.get_cursor_range()

  opts = opts or {}

  local filetype = vim.bo.filetype
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  local these_commands = {}

  for _, client in ipairs(clients) do
    local client_seen_cmds = {}
    for command, _ in pairs(client.commands or {}) do
      if not client_seen_cmds[command] and matches_lsp_command(command, filetype) then
        client_seen_cmds[command] = true
        local name = "[" .. client.name .. "] " .. command
        these_commands[#these_commands + 1] = {
          name = name,
          id = command,
          category = "LS",
          action = function()
            client:exec_cmd({ command = command, title = name, arguments = { M.current_cursor } }, { bufnr = 0 })
          end,
        }
      end
    end

    local command_provider = client.server_capabilities.executeCommandProvider or {}
    for _, command in ipairs(command_provider.commands or {}) do
      if not client_seen_cmds[command] and matches_lsp_command(command, filetype) then
        client_seen_cmds[command] = true
        local name = "[" .. client.name .. "] " .. command
        these_commands[#these_commands + 1] = {
          name = name,
          id = command,
          category = "LS",
          action = function()
            client:exec_cmd({ command = command, title = name, arguments = { M.current_cursor } }, { bufnr = 0 })
          end,
        }
      end
    end
  end

  for _, command in ipairs(M.commands) do
    if matches_filetype(command.filetype, filetype) then
      these_commands[#these_commands + 1] = command
    end
  end

  SnacksPicker.select(these_commands, {
    prompt = "Common commands",
    format_item = function(item, supports_chunks)
      if not supports_chunks then
        return string.format("%s  %s", item.name, item.category)
      end

      return {
        { item.name },
        { "  " },
        { item.category, "SnacksPickerComment" },
      }
    end,
    snacks = vim.tbl_deep_extend("force", {
      hidden = { "preview" },
      layout = { preset = "select" },
    }, opts.snacks or {}),
  }, function(selection)
    if not selection then
      return
    end

    selection.action({ cursor = M.current_cursor })
  end)
end

--- @param cursor CursorRange
--- @return string
M.build_range_prefix = function(cursor)
  if cursor.visual then
    return cursor.start.line .. "," .. cursor.stop.line
  else
    return tostring(cursor.start.line)
  end
end

--- @param cursor CursorRange
M.restore_selection = function(cursor)
  if cursor and cursor.visual then
    vim.api.nvim_buf_set_mark(0, "<", cursor.start.line, cursor.start.col, {})
    vim.api.nvim_buf_set_mark(0, ">", cursor.stop.line, cursor.stop.col, {})
  end
end

M.setup = function()
  vim.keymap.set("n", "<leader>k", show_common_commands_picker, { desc = "Open command bar" })
  vim.keymap.set("v", "<leader>k", show_common_commands_picker, { desc = "Open command bar" })
end

return M
