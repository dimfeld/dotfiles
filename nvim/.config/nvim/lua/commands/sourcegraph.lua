local M = {}

local cmdbar = require('config.telescope_commandbar')

local cody = require('sg.cody.commands')
local pickers = require('telescope.pickers')
local finders = require 'telescope.finders'
local conf = require 'telescope.config'.values
local actions = require 'telescope.actions'
local action_state = require 'telescope.actions.state'

local getLineRange = function()
  local startPos, endPos = vim.api.nvim_buf_get_mark(0, "<"), vim.api.nvim_buf_get_mark(0, ">")
  local startLine = startPos[1]
  local endLine =  endPos[1]

  return startLine, endLine
end

M.ask_cody = function()
  local popup_opts = {
    prompt = "Ask your question: ",
  }

  local startLine, endLine = getLineRange()

  local doIt = function(q)
    if q == nil then
      return
    end

    cody.ask_range(0, startLine, endLine, q)
  end

  vim.ui.input(popup_opts, doIt)
end

M.cody_task = function()
  local popup_opts = {
    prompt = "Describe your task: ",
  }

  local doIt = function(q)
    if q == nil then
      return
    end

    -- The CodyTask command does extra bookkeeping that is required to make things like
    -- accepting the Task work properly, so just use that.
    vim.cmd('CodyTask ' .. q)
  end

  vim.ui.input(popup_opts, doIt)
end

M.cody_task_recipe = function(opts)
  opts = opts or {}

  local tasks = {
    { task = "Add a documentation comment to this function" }
  }

  pickers.new(opts, {
    prompt_title = 'Select a task',
    finder = finders.new_table {
      results = tasks,
      entry_maker = function(entry)
        return {
          value = entry,
          display = function(ent)
            return ent.value.label or ent.value.task
          end,
          ordinal = entry.label or entry.task
        }
      end
    },
    sorter = conf.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr, map)
      map('i', '<CR>', function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry(prompt_bufnr)

        local value = selection.value
        vim.cmd('CodyTask ' .. value.task)
      end)
      return true
    end,
  }):find()
end

cmdbar.add_commands({
  { name = "Cody Chat - New", category = "Sourcegraph", action = function() cody.chat() end },
  { name = "Cody Chat - History", category = "Sourcegraph", action = function() cody.history() end },
  { name = "Cody Chat - Toggle", category = "Sourcegraph", action = function() cody.toggle() end },
  { name = "Cody Chat - Focus History", category = "Sourcegraph", action = function() cody.focus_history() end },
  { name = "Cody Chat - Focus Prompt", category = "Sourcegraph", action = function() cody.focus_prompt() end },
  { name = "Ask Cody", category = "Sourcegraph", action = function() M.ask_cody() end },
  { name = "Cody Task", category = "Sourcegraph", action = function() M.cody_task() end },
  { name = "Cody Task from List", category = "Sourcegraph", action = function() M.cody_task_recipe() end },
})

return M
