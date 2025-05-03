local M = {}

local window = require("lib.window")
local telescope = require("telescope")
local builtin = require("telescope.builtin")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local entry_display = require("telescope.pickers.entry_display")

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

--- @type CommandBarAction[]
M.commands = {
  {
    name = "Organize imports",
    category = "LS",
    filetype = "typescript",
    action = function()
      for _, client in ipairs(vim.lsp.get_clients()) do
        -- local ac = client.capabilities.textDocument.codeAction.codeActionLiteralSupport.codeActionKind.valueSet
        local ac = client.server_capabilities
            and client.server_capabilities.codeActionProvider
            and client.server_capabilities.codeActionProvider.codeActionKinds
          or {}

        for _, action in ipairs(ac) do
          if action == "source.organizeImports" then
            vim.lsp.buf.code_action({
              context = {
                only = { "source.organizeImports" },
              },
              apply = true,
            })

            -- client:exec_cmd({ command = "source.organizeImports", arguments = { vim.uri_from_bufnr(0) } })
            return
          end
        end
      end
    end,
  },
  {
    name = "Remove Unused imports",
    category = "LS",
    filetype = "typescript",
    action = function()
      vim.lsp.buf.execute_command({
        command = "typescript.removeUnusedImports",
        arguments = { vim.fn.expand("%:p") },
      })
    end,
  },
  -- { name = "Format document", category = "LS", coc_cmd = "editor.action.formatDocument" },
  -- { name = "Format selection", category = "LS", coc_cmd = "editor.action.formatSelection" },
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
  -- { name = "Go to Definition", category = "LS", coc_cmd = "editor.action.goToDeclaration" },
  -- { name = "Go to Implementation", category = "LS", coc_cmd = "editor.action.goToImplementation" },
  -- { name = "Go to Type Definition", category = "LS", coc_cmd = "editor.action.goToTypeDefinition" },
  -- { name = "Go to References", category = "LS", coc_cmd = "editor.action.goToReferences" },
  {
    name = "Restart Svelte LS",
    category = "LS",
    action = function()
      vim.cmd("LspRestart svelte")
    end,
  },
  -- {
  --   name = "Reload Rust Analyzer Workspace",
  --   category = "LS",
  --   filetype = "rust",
  --   coc_cmd = "rust-analyzer.reloadWorkspace",
  -- },
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
  -- { name = "Reload Typescript Project", category = "LS", coc_cmd = "tsserver.reloadProjects" },
  -- { name = "Show LS Output", category = "LS", coc_cmd = "workspace.showOutput" },

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
      -- The `s` command updates the highlight, so restore whatever was there before.
      vim.fn.setreg("/", saved_hl)
    end,
  },
  {
    name = "View Undo Tree",
    category = "Editing",
    action = function()
      require("telescope").extensions.undo.undo()
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
    name = "Call LLM without Operation",
    category = "AI",
    action = function()
      require("commands.llm").fill_holes({
        cursor = M.current_cursor,
      })
    end,
  },

  {
    name = "Ask LLM",
    category = "AI",
    action = function()
      require("commands.llm").ask_and_fill_holes({
        cursor = M.current_cursor,
      })
    end,
  },

  {
    name = "Set Default Model",
    category = "AI",
    action = function()
      vim.ui.input({
        prompt = "Model: ",
      }, function(model)
        if not model then
          return
        end

        require("commands.llm").set_default_model(model)
      end)
    end,
  },

  {
    name = "Set Avante Model",
    category = "AI",
    action = function()
      vim.cmd("AvanteModels")
    end,
  },

  {
    name = "rmfilter on current buffer",
    category = "AI",
    action = vim.schedule_wrap(function()
      require("commands.rmfilter").ask_rmfilter()
    end),
  },
  {
    name = "Apply rmfilter edits",
    category = "AI",
    action = vim.schedule_wrap(function()
      require("commands.rmfilter").apply_edits()
    end),
  },
}

--- @param commands CommandBarAction[]
M.add_commands = function(commands)
  for _, command in ipairs(commands) do
    table.insert(M.commands, command)
  end
end

local function showCommonCommandsPicker(opts)
  -- Grab the current cursor here since we'll lose any visual selection once the picker opens.
  M.current_cursor = window.get_cursor_range()

  opts = opts or {}

  local filetype = vim.bo.filetype
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  local lsp_commands = {}
  for _, client in ipairs(clients) do
    local client_seen_cmds = {}
    for command, _ in pairs(client.commands) do
      if not client_seen_cmds[command] then
        client_seen_cmds[command] = true

        local name = "[" .. client.name .. "] " .. command
        table.insert(lsp_commands, {
          name = name,
          id = command,
          category = "LS",
          action = function()
            client:exec_cmd({ command = command, title = name, arguments = { M.current_cursor } }, { bufnr = 0 })
          end,
        })
      end
    end

    local command_provider = client.server_capabilities.executeCommandProvider or {}
    local this_commands = command_provider.commands or {}
    for _, command in ipairs(this_commands) do
      if not client_seen_cmds[command] then
        local name = "[" .. client.name .. "] " .. command
        table.insert(lsp_commands, {
          name = name,
          id = command,
          category = "LS",
          action = function()
            client:exec_cmd({ command = command, title = name, arguments = { M.current_cursor } }, { bufnr = 0 })
          end,
        })
      end
    end
  end

  local longest_command_name = 0
  local these_commands = {}
  for i, command in ipairs(lsp_commands) do
    local id = command.id

    if vim.startswith(id, "rust-analyzer.") == 1 and filetype ~= "rust" then
      goto continue
    elseif vim.startswith(id, "pyright.") and filetype ~= "python" then
      goto continue
    elseif vim.startswith(id, "python.") and filetype ~= "python" then
      goto continue
    elseif vim.startswith(id, "svelte.") and filetype ~= "svelte" then
      goto continue
    elseif vim.startswith(id, "_typescript.") then
      -- Internal commands for code actions
      goto continue
    elseif vim.startswith(id, "typescript.") or vim.startswith(id, "javascript.") then
      if filetype ~= "typescript" and filetype ~= "javascript" and filetype ~= "svelte" then
        goto continue
      end

      if
        ((filetype == "typescript" or filetype == "svelte") and vim.startswith(id, "javascript"))
        or (filetype == "javascript" and vim.startswith(id, "typescript"))
      then
        goto continue
      end
    end

    these_commands[#these_commands + 1] = command
    if #command.name > longest_command_name then
      longest_command_name = #command.name
    end

    ::continue::
  end

  for i, command in ipairs(M.commands) do
    if command.filetype ~= nil and filetype ~= command.filetype then
      if filetype == "svelte" and command.filetype == "typescript" then
      -- allow this
      else
        goto continue_2
      end
    end

    these_commands[#these_commands + 1] = command
    if #command.name > longest_command_name then
      longest_command_name = #command.name
    end

    ::continue_2::
  end

  local displayer = entry_display.create({
    separator = " ",
    items = {
      { width = longest_command_name + 2 },
      { remaining = true },
    },
  })

  pickers
    .new(opts, {
      prompt_title = "Common commands",
      finder = finders.new_table({
        results = these_commands,
        entry_maker = function(entry)
          return {
            value = entry,
            display = function(ent)
              return displayer({
                ent.value.name,
                { ent.value.category, "TelescopeResultsComment" },
              })
            end,
            ordinal = entry.name,
          }
        end,
      }),
      sorter = conf.generic_sorter(opts),
      attach_mappings = function(prompt_bufnr, map)
        map("i", "<CR>", function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry(prompt_bufnr)

          selection.value.action({ cursor = M.current_cursor })
        end)
        return true
      end,
    })
    :find()
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
  vim.keymap.set("n", "<leader>k", showCommonCommandsPicker, { desc = "Open command bar" })
  vim.keymap.set("v", "<leader>k", showCommonCommandsPicker, { desc = "Open command bar" })
end

return M
