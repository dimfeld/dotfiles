local M = {}

local telescope = require('telescope');

telescope.load_extension('coc');
telescope.load_extension('dap');
telescope.load_extension('file_browser');

function waitForCocLoaded()
  vim.wait(2000, function() return vim.g.coc_service_initialized == 1 end, 50)
end

local telescope = require('telescope.builtin')
MUtils.findFilesInCocWorkspace = function()
  waitForCocLoaded()
  local currentWorkspace = vim.fn.CocAction('currentWorkspacePath')
  telescope.find_files({ cwd=currentWorkspace })
end

MUtils.liveGrepInCocWorkspace = function()
  waitForCocLoaded()
  local currentWorkspace = vim.fn.CocAction('currentWorkspacePath')
  telescope.live_grep({ cwd=currentWorkspace })
end


local pickers = require 'telescope.pickers'
local finders = require 'telescope.finders'
local conf = require 'telescope.config'.values
local actions = require 'telescope.actions'
local action_state = require 'telescope.actions.state'
local entry_display = require 'telescope.pickers.entry_display'

local commands = {
  { name = 'Organize imports', category = "LS", action = function() vim.fn.CocAction('runCommand', 'editor.action.organizeImport') end },
  { name = 'Format document', category = "LS", action = function() vim.fn.CocAction('runCommand', 'editor.action.formatDocument') end },
  { name = 'Format selection', category = "LS", action = function() vim.fn.CocAction('runCommand', 'editor.action.formatSelection') end },
  { name = 'Rename symbol', category = "LS", action = function() vim.fn.CocAction('runCommand', 'editor.action.rename') end },
  { name = 'Go to Definition', category = "LS", action = function() vim.fn.CocAction('runCommand', 'editor.action.goToDeclaration') end },
  { name = 'Go to Implementation', category = "LS", action = function() vim.fn.CocAction('runCommand', 'editor.action.goToImplementation') end },
  { name = 'Go to Type Definition', category = "LS", action = function() vim.fn.CocAction('runCommand', 'editor.action.goToTypeDefinition') end },
  { name = 'Go to References', category = "LS", action = function() vim.fn.CocAction('runCommand', 'editor.action.goToReferences') end },
  { name = 'Restart Svelte LS', category = "LS", action = function() vim.fn.CocAction('runCommand', 'svelte.restartLanguageServer') end },
  { name = 'Restart Typescript LS', category = "LS", action = function() vim.fn.CocAction('runCommand', 'tsserver.restart') end },
  { name = 'Reload Rust Analyzer Workspace', category = "LS", action = function() vim.fn.CocAction('runCommand', 'rust-analyzer.reloadWorkspace') end  },
  { name = 'Reload Typescript Project', category = "LS", action = function() vim.fn.CocAction('runCommand', 'tsserver.reloadProjects') end },
  { name = 'Show LS Output', category = "LS", action = function() vim.fn.CocAction('runCommand', 'workspace.showOutput') end },

  { name = "Git permalink", category = "Git", action = function() vim.fn.CocAction('runCommand', 'git.copyPermalink') end },
  { name = "Git blame popup", category = "Git", action = function() vim.fn.CocAction('runCommand', 'git.showBlameDoc') end },
  { name = 'Open line in Github', category = "Git", action = function() vim.fn.CocAction('runCommand', 'git.browserOpen') end },
  { name = 'Show last Git commit', category = "Git", action = function() vim.fn.CocAction('runCommand', 'git.showCommit') end },
  { name = 'Undo Git chunk', category = "Git", action = function() vim.fn.CocAction('runCommand', 'git.chunkUndo') end },
  { name = 'Unstage Git chunk', category = "Git", action = function() vim.fn.CocAction('runCommand', 'git.chunkUnstage') end },
  { name = 'Stage Git chunk', category = "Git", action = function() vim.fn.CocAction('runCommand', 'git.chunkStage') end },
  { name = 'Git chunk Info', category = "Git", action = function() vim.fn.CocAction('runCommand', 'git.chunkInfo') end },
  { name = 'Git Difftool', category = "Git",  action = function () vim.cmd('Git difftool') end },
  { name = 'Git Blame', category = "Git",  action = function () vim.cmd('Git blame') end },

  { name = 'Vertical Terminal', category = "Terminal", action = function () vim.cmd('VTerm') end },
  { name = 'Horizontal Terminal', category = "Terminal", action = function () vim.cmd('HTerm') end },
}


M.showCommonCommandsPicker = function(opts)
  opts = opts or {}

  local filetype = vim.bo.filetype
  local coc_commands = vim.fn.CocAction('commands')

  local longest_command_name = 0
  local these_commands = {}
  for i, command in ipairs(coc_commands) do
    local id = command.id

    if id:find('rust-analyzer.', 1, true) == 1 and filetype ~= 'rust' then
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
      action = function() vim.fn.CocAction('runCommand', command.id) end,
    }

    these_commands[#these_commands+1] = converted_command
    if #converted_command.name > longest_command_name then
      longest_command_name = #converted_command.name
    end

    ::continue::
  end

  for i, command in ipairs(commands) do
    these_commands[#these_commands+1] = command
    if #command.name > longest_command_name then
      longest_command_name = #command.name
    end
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
        selection.value.action()
      end)
      return true
    end,
  }):find()

end

return M
