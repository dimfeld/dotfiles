local M = {}

local telescope = require('telescope');

telescope.load_extension('coc');
telescope.load_extension('dap');
telescope.load_extension('file_browser');
telescope.load_extension('fzy_native');
telescope.load_extension('smart_open');

function waitForCocLoaded()
  vim.wait(2000, function() return vim.g.coc_service_initialized == 1 end, 50)
end

local builtin = require('telescope.builtin')
MUtils.findFilesInCocWorkspace = function()
  waitForCocLoaded()
  local currentWorkspace = vim.fn.CocAction('currentWorkspacePath')
  builtin.find_files({ cwd=currentWorkspace })
end

MUtils.liveGrepInCocWorkspace = function()
  waitForCocLoaded()
  local currentWorkspace = vim.fn.CocAction('currentWorkspacePath')
  builtin.live_grep({ cwd=currentWorkspace })
end


local pickers = require 'telescope.pickers'
local finders = require 'telescope.finders'
local conf = require 'telescope.config'.values
local actions = require 'telescope.actions'
local action_state = require 'telescope.actions.state'
local entry_display = require 'telescope.pickers.entry_display'

local commands = {
  { name = 'Organize imports', category = "LS", coc_cmd = "editor.action.organizeImport" },
  { name = 'Format document', category = "LS", coc_cmd = "editor.action.formatDocument" },
  { name = 'Format selection', category = "LS", coc_cmd = "editor.action.formatSelection" },
  { name = 'Rename symbol', category = "LS", coc_cmd = "editor.action.rename" },
  { name = 'Go to Definition', category = "LS", coc_cmd = "editor.action.goToDeclaration" },
  { name = 'Go to Implementation', category = "LS", coc_cmd = "editor.action.goToImplementation" },
  { name = 'Go to Type Definition', category = "LS", coc_cmd = "editor.action.goToTypeDefinition" },
  { name = 'Go to References', category = "LS", coc_cmd = "editor.action.goToReferences" },
  { name = 'Restart Svelte LS', category = "LS", coc_cmd = "svelte.restartLanguageServer" },
  { name = 'Reload Rust Analyzer Workspace', category = "LS", filetype = "rust", coc_cmd = "rust-analyzer.reloadWorkspace"  },
  { name = 'Restart Typescript LS', category = "LS", coc_cmd = "tsserver.restart" },
  { name = 'Reload Typescript Project', category = "LS", coc_cmd = "tsserver.reloadProjects" },
  { name = 'Show LS Output', category = "LS", coc_cmd = "workspace.showOutput" },

  { name = "Git permalink", category = "Git", coc_cmd = "git.copyPermalink" },
  { name = "Git blame popup", category = "Git", coc_cmd = "git.showBlameDoc" },
  { name = 'Open line in Github', category = "Git", coc_cmd = "git.browserOpen" },
  { name = 'Show last Git commit', category = "Git", coc_cmd = "git.showCommit" },
  { name = 'Undo Git chunk', category = "Git", coc_cmd = "git.chunkUndo" },
  { name = 'Unstage Git chunk', category = "Git", coc_cmd = "git.chunkUnstage" },
  { name = 'Stage Git chunk', category = "Git", coc_cmd = "git.chunkStage" },
  { name = 'Git chunk Info', category = "Git", coc_cmd = "git.chunkInfo" },
  { name = 'Git Difftool', category = "Git",  action = function () vim.cmd('Git difftool') end },
  { name = 'Git Blame', category = "Git",  action = function () vim.cmd('Git blame') end },
  { name = 'Git 3-way Diff', category = "Git",  action = function () vim.cmd('Gvdiffsplit') end },
  { name = "Git Status", category = "Git", action = builtin.git_status },

  { name = 'Resync Syntax', category = "Buffer", action = function () vim.cmd('syntax sync fromstart') end },

  { name = 'Vertical Terminal', category = "Terminal", action = function () vim.cmd('VTerm') end },
  { name = 'Horizontal Terminal', category = "Terminal", action = function () vim.cmd('HTerm') end },

  { name = 'Quickfix Search', category = "Quickfix", action = builtin.quickfix },
  { name = 'Quickfix History', category = "Quickfix", action = builtin.quickfixhistory },

  { name = "Yank to Clipboard", category = "Clipboard", action = function() vim.cmd("'<,'>y*") end },
  { name = "Delete to Blackhole", category = "Clipboard", action = function() vim.cmd("'<,'>d_") end },
}

local handled_coc_commands = {}
for _, command in ipairs(commands) do
  if command.coc_cmd then
    handled_coc_commands[command.coc_cmd] = true
  end
end

M.showCommonCommandsPicker = function(opts)
  opts = opts or {}

  local filetype = vim.bo.filetype
  local coc_commands = vim.fn.CocAction('commands')

  local longest_command_name = 0
  local these_commands = {}
  for i, command in ipairs(coc_commands) do
    local id = command.id

    if handled_coc_commands[id] == true then
      goto continue
    elseif id:find('rust-analyzer.', 1, true) == 1 and filetype ~= 'rust' then
      goto continue
    elseif id:find('pyright.', 1, true) == 1 and filetype ~= 'python' then
      goto continue
    elseif id:find('python.', 1, true) == 1 and filetype ~= 'python' then
      goto continue
    elseif id:find('svelte.', 1, true) == 1 and filetype ~= 'svelte' then
      goto continue
    elseif id:find('tsserver.', 1, true) == 1 and filetype ~= 'typescript' then
      goto continue
    end

    local title = command.title
    if title == '' then
      title = command.id
    end
    converted_command = {
      name = title,
      category = command.id,
      coc_cmd = command.id,
    }

    these_commands[#these_commands+1] = converted_command
    if #converted_command.name > longest_command_name then
      longest_command_name = #converted_command.name
    end

    ::continue::
  end

  for i, command in ipairs(commands) do
    if command.filetype ~= nil and filetype ~= command.filetype then
      goto continue_2
    end

    these_commands[#these_commands+1] = command
    if #command.name > longest_command_name then
      longest_command_name = #command.name
    end

    ::continue_2::
  end

  local displayer = entry_display.create {
    separator = " ",
    items = {
      { width = longest_command_name + 2 },
      { remaining = true },
    },
  }

  pickers.new(opts, {
    prompt_title = 'Common commands',
    finder = finders.new_table {
      results = these_commands,
      entry_maker = function(entry)
        return {
          value = entry,
          display = function(ent)
            return displayer {
              ent.value.name,
              { ent.value.category, "TelescopeResultsComment" }
            }
          end,
          ordinal = entry.name,
        }
      end,
    },
    sorter = conf.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr, map)
      map('i', '<CR>', function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry(prompt_bufnr)

        local value = selection.value
        if value.coc_cmd ~= nil then
          vim.fn.CocActionAsync('runCommand', value.coc_cmd)
        elseif value.action ~= nil then
          value.action()
        end
      end)
      return true
    end,
  }):find()

end

return M
