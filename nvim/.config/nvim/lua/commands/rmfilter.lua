local M = {}

-- Store last used arguments
local last_args = ""
local last_instructions = ""

local function show_rmfilter_dialog(submit)
  -- Require nui.nvim components
  local Input = require("nui.input")
  local Layout = require("nui.layout")

  local function exec_in_window(winid, command)
    vim.schedule(function() end)
  end

  -- Create input fields
  local args_input = Input({
    position = "50%",
    size = { width = 60 },
    border = { style = "rounded", text = { top = "Arguments" } },
    win_options = { winhighlight = "Normal:Normal,FloatBorder:Normal" },
  }, {
    prompt = "> ",
    default_value = last_args,
    on_submit = function() end, -- Will be overridden
  })

  local instructions_input = Input({
    position = "50%",
    size = { width = 60, height = 10 },
    border = { style = "rounded", text = { top = "Instructions" } },
    win_options = { winhighlight = "Normal:Normal,FloatBorder:Normal" },
  }, {
    prompt = "",
    default_value = last_instructions,
    on_submit = function() end, -- Will be overridden
  })

  -- Create layout to stack inputs vertically
  local layout = Layout(
    {
      position = "50%",
      size = { width = 60, height = 16 },
    },
    Layout.Box({
      Layout.Box(args_input, { size = 3 }),
      Layout.Box(instructions_input, { size = 13 }),
    }, { dir = "col" })
  )

  -- Keymaps for navigation
  local function set_navigation_keymaps(input, next_input)
    input:map("i", "<Tab>", function()
      vim.api.nvim_set_current_win(next_input.winid)
    end, { noremap = true, silent = true })
    input:map("i", "<S-Tab>", function()
      vim.api.nvim_set_current_win(next_input.winid)
    end, { noremap = true, silent = true })
    input:map("n", "<Tab>", function()
      vim.api.nvim_set_current_win(next_input.winid)
    end, { noremap = true, silent = true })
    input:map("n", "<S-Tab>", function()
      vim.api.nvim_set_current_win(next_input.winid)
    end, { noremap = true, silent = true })
  end

  set_navigation_keymaps(args_input, instructions_input)
  set_navigation_keymaps(instructions_input, args_input)

  -- Keymaps for cancel
  local function set_cancel_keymaps(input)
    input:map("n", "<Esc>", function()
      layout:unmount()
    end, { noremap = true, silent = true })
  end

  set_cancel_keymaps(args_input)
  set_cancel_keymaps(instructions_input)

  local function call_submit()
    local args = args_input:get_value() or ""
    local instructions = instructions_input:get_value() or ""

    -- Store inputs for next time
    last_args = args
    last_instructions = instructions

    layout:unmount()

    submit(args_input:get_value(), instructions_input:get_value())
  end

  -- Set submit keymaps
  args_input:map("i", "<CR>", call_submit, { noremap = true, silent = true })
  instructions_input:map("i", "<CR>", call_submit, { noremap = true, silent = true })

  -- Mount the layout
  layout:mount()

  vim.defer_fn(function()
    vim.api.nvim_set_current_win(instructions_input.winid)
    vim.api.nvim_command("noautocmd startinsert!")
    vim.api.nvim_set_current_win(args_input.winid)
    vim.api.nvim_command("noautocmd startinsert!")
  end, 25)
end

function M.ask_rmfilter()
  -- Get repository root
  local repo_root = require("lib.git").git_repo_toplevel()
  if not repo_root then
    vim.notify("Not in a git repository", vim.log.levels.ERROR)
    return
  end

  -- Get current buffer's filename relative to repo root
  local bufname = vim.api.nvim_buf_get_name(0)
  local relative_path = vim.fn.fnamemodify(bufname, ":p")
  relative_path = relative_path:sub(#repo_root + 2) -- Remove repo_root path + leading slash

  show_rmfilter_dialog(function(args, instructions)
    if args == "" and instructions == "" then
      return
    end

    -- Construct and execute command
    local cmd = string.format("rmfilter --copy %s %s", vim.fn.shellescape(relative_path), args)
    if instructions ~= "" then
      cmd = cmd .. " --instructions " .. vim.fn.shellescape(instructions)
    end

    local output = vim.fn.system(cmd)

    -- Create a new buffer for output
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(output, "\n"))
    vim.api.nvim_set_option_value("filetype", "text", { buf = buf })
    vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
    vim.api.nvim_buf_set_name(buf, "rmfilter output")

    -- Set keymap to close buffer with 'q'
    vim.api.nvim_buf_set_keymap(buf, "n", "q", ":bdelete<CR>", { noremap = true, silent = true })

    -- Open the buffer in a new window
    vim.api.nvim_command("vsplit | buffer " .. buf)

    -- Check for errors
    if vim.v.shell_error ~= 0 then
      vim.notify("rmfilter failed: " .. cmd, vim.log.levels.ERROR)
    else
      vim.notify("rmfilter executed: " .. cmd, vim.log.levels.INFO)
    end
  end)
end

function M.apply_edits()
  local output = vim.fn.system("apply-llm-edits")

  -- Create a new buffer for output
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(output, "\n"))
  vim.api.nvim_set_option_value("filetype", "text", { buf = buf })
  vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
  vim.api.nvim_buf_set_name(buf, "apply-llm-edits output")

  -- Set keymap to close buffer with 'q'
  vim.api.nvim_buf_set_keymap(buf, "n", "<Esc><Esc>", ":bdelete<CR>", { noremap = true, silent = true })

  -- Open the buffer in a new window
  vim.api.nvim_command("vsplit | buffer " .. buf)

  if vim.v.shell_error ~= 0 then
    vim.notify("apply failed!", vim.log.levels.ERROR)
  else
    vim.notify("apply succeeded!", vim.log.levels.INFO)

    -- Get repository root
    local repo_root = require("lib.git").git_repo_toplevel()
    if repo_root then
      -- Parse output for unique filenames (format: "Applying diff to ${filename} ...")
      local seen_filenames = {}
      local unique_filenames = {}
      for _, line in ipairs(vim.split(output, "\n")) do
        local filename = line:match("^Applying diff to ([^%s]+)")
        if filename and not seen_filenames[filename] then
          seen_filenames[filename] = true
          table.insert(unique_filenames, filename)
        end
      end

      -- Process each unique filename
      for _, filename in ipairs(unique_filenames) do
        -- Convert relative path to absolute
        local absolute_path = repo_root .. "/" .. filename
        -- Check all active buffers
        for _, buf_id in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_is_loaded(buf_id) then
            local buf_name = vim.api.nvim_buf_get_name(buf_id)
            if buf_name == absolute_path then
              -- Reload the buffer
              vim.api.nvim_buf_call(buf_id, function()
                vim.cmd("edit!")
              end)
            end
          end
        end
      end
    end
  end
end

return M
