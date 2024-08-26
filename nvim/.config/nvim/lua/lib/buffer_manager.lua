local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local M = {}

M.get_eligible_buffer_list = function()
  -- Return all buffers that correspond to actual files
  local buffers = vim.api.nvim_list_bufs()
  local eligible_buffers = {}
  for _, buf in ipairs(buffers) do
    local filename = vim.api.nvim_buf_get_name(buf)
    if filename ~= "" then
      table.insert(eligible_buffers, buf)
    end
  end
  return eligible_buffers
end

M.show_buffer_selector = function(managed_buffers)
  local buffers = M.get_eligible_buffer_list()
  local make_finder = function()
    return finders.new_table({
      results = buffers,
      entry_maker = function(buf)
        local filename = vim.api.nvim_buf_get_name(buf)
        local is_managed = vim.tbl_contains(managed_buffers, buf)
        local icon = is_managed and "+ " or "- "
        return {
          value = buf,
          display = icon .. filename,
          ordinal = filename,
        }
      end,
    })
  end

  pickers
    .new({}, {
      prompt_title = "Manage Buffers",
      finder = make_finder(),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(prompt_bufnr, map)
        map({ "i", "n" }, "<CR>", function()
          local picker = action_state.get_current_picker(prompt_bufnr)
          local selection = action_state.get_selected_entry()

          local buf = selection.value
          local index = nil
          for i, value in ipairs(managed_buffers) do
            if value == buf then
              index = i
              break
            end
          end

          if index then
            table.remove(managed_buffers, index)
          else
            table.insert(managed_buffers, buf)
          end

          local current_row = picker:get_selection_row()
          picker:refresh(make_finder())
          picker:set_selection(current_row)
        end)
        return true
      end,
    })
    :find()
end

M.create_buffer_manager = function(opts)
  opts = opts or {}
  local autoattach = opts.autoattach

  local managed_buffers = {}

  local augroup
  if autoattach then
    augroup = vim.api.nvim_create_augroup("BufferManager", { clear = true })

    vim.api.nvim_create_autocmd("BufAdd", {
      group = augroup,
      callback = function(args)
        table.insert(managed_buffers, args.buf)
      end,
    })

    vim.api.nvim_create_autocmd("BufDelete", {
      group = augroup,
      callback = function(args)
        for i, buf in ipairs(managed_buffers) do
          if buf == args.buf then
            table.remove(managed_buffers, i)
            break
          end
        end
      end,
    })

    local buffers = M.get_eligible_buffer_list()
    for _, buf in ipairs(buffers) do
      table.insert(managed_buffers, buf)
    end
  end

  return {
    select = function()
      M.show_buffer_selector(managed_buffers)
    end,
    destroy = function()
      if augroup then
        vim.api.nvim_del_augroup_by_id(augroup)
      end
    end,
    buffers = managed_buffers,
    buffer_filenames = function()
      return vim.tbl_map(function(buf)
        return vim.api.nvim_buf_get_name(buf)
      end, managed_buffers)
    end,
  }
end

M.test_manager = M.create_buffer_manager({ autoattach = true })

return M
