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

-- Information about the current cursor position, useful when running a command that needs to access the visual
-- selection since opening the picker will lose it.
M.current_cursor = nil

M.commands = {
  { name = "Organize imports", category = "LS", coc_cmd = "editor.action.organizeImport" },
  { name = "Format document", category = "LS", coc_cmd = "editor.action.formatDocument" },
  { name = "Format selection", category = "LS", coc_cmd = "editor.action.formatSelection" },
  { name = "Rename symbol", category = "LS", coc_cmd = "editor.action.rename" },
  { name = "Go to Definition", category = "LS", coc_cmd = "editor.action.goToDeclaration" },
  { name = "Go to Implementation", category = "LS", coc_cmd = "editor.action.goToImplementation" },
  { name = "Go to Type Definition", category = "LS", coc_cmd = "editor.action.goToTypeDefinition" },
  { name = "Go to References", category = "LS", coc_cmd = "editor.action.goToReferences" },
  { name = "Restart Svelte LS", category = "LS", coc_cmd = "svelte.restartLanguageServer" },
  {
    name = "Reload Rust Analyzer Workspace",
    category = "LS",
    filetype = "rust",
    coc_cmd = "rust-analyzer.reloadWorkspace",
  },
  { name = "Restart Typescript LS", category = "LS", coc_cmd = "tsserver.restart" },
  { name = "Reload Typescript Project", category = "LS", coc_cmd = "tsserver.reloadProjects" },
  { name = "Show LS Output", category = "LS", coc_cmd = "workspace.showOutput" },

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
    action = function()
      local saved_hl = vim.fn.getreg("/")
      local cmd = M.current_cursor.start.line .. "," .. M.current_cursor.stop.line .. [[s/\S/pub &/e]]
      vim.cmd(cmd)
      -- The `s` command updaes the highlight, so restore whatever was there before.
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
    action = function()
      vim.cmd("'<,'>y*")
    end,
  },
  {
    name = "Delete to Blackhole",
    category = "Clipboard",
    action = function()
      vim.cmd("'<,'>d_")
    end,
  },

  { name = "Aider", category = "AI", action = AiderOpen },
  { name = "Aider Background", category = "AI", action = AiderBackground },

  {
    name = "Codeium Chat",
    category = "AI",
    action = function()
      vim.cmd("Codeium Chat")
      -- vim.fn["codeium#Chat"]()
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
}

M.add_commands = function(commands)
  for _, command in ipairs(commands) do
    table.insert(M.commands, command)
  end
end

-- After everything has initialized, see which CoC commands have been handled
local handled_coc_commands = {}
vim.schedule(function()
  for _, command in ipairs(M.commands) do
    if command.coc_cmd then
      handled_coc_commands[command.coc_cmd] = true
    end
  end
end)

function showCommonCommandsPicker(opts)
  -- Grab the current cursor here since we'll lose any visual selection once the picker opens.
  M.current_cursor = window.get_cursor_range()

  opts = opts or {}

  local filetype = vim.bo.filetype
  local coc_commands = vim.fn.CocAction("commands")

  local longest_command_name = 0
  local these_commands = {}
  for i, command in ipairs(coc_commands) do
    local id = command.id

    if handled_coc_commands[id] == true then
      goto continue
    elseif id:find("rust-analyzer.", 1, true) == 1 and filetype ~= "rust" then
      goto continue
    elseif id:find("pyright.", 1, true) == 1 and filetype ~= "python" then
      goto continue
    elseif id:find("python.", 1, true) == 1 and filetype ~= "python" then
      goto continue
    elseif id:find("svelte.", 1, true) == 1 and filetype ~= "svelte" then
      goto continue
    elseif id:find("tsserver.", 1, true) == 1 and filetype ~= "typescript" then
      goto continue
    end

    local title = command.title
    if title == "" then
      title = command.id
    end
    converted_command = {
      name = title,
      category = command.id,
      coc_cmd = command.id,
    }

    these_commands[#these_commands + 1] = converted_command
    if #converted_command.name > longest_command_name then
      longest_command_name = #converted_command.name
    end

    ::continue::
  end

  for i, command in ipairs(M.commands) do
    if command.filetype ~= nil and filetype ~= command.filetype then
      goto continue_2
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

          local value = selection.value
          if value.coc_cmd ~= nil then
            vim.fn.CocActionAsync("runCommand", value.coc_cmd)
          elseif value.action ~= nil then
            value.action()
          end
        end)
        return true
      end,
    })
    :find()
end

M.setup = function()
  vim.keymap.set("n", "<leader>k", showCommonCommandsPicker, { desc = "Open command bar" })
  vim.keymap.set("v", "<leader>k", showCommonCommandsPicker, { desc = "Open command bar" })
end

return M
