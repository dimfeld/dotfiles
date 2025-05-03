local M = {}

-- Store last used arguments
local last_args = ""
local last_instructions = ""
local last_model = "grok"

local function show_rmfilter_dialog(submit)
  -- Require nui.nvim components
  local Input = require("nui.input")
  local Popup = require("nui.popup")
  local Layout = require("nui.layout")

  local win_width = vim.api.nvim_win_get_width(0)
  local win_height = vim.api.nvim_win_get_height(0)

  local width = 120
  local max_width = math.floor(win_width * 0.8)

  if width > max_width then
    width = max_width
  end

  -- Create input fields
  local args_input = Popup({
    position = "50%",
    size = { width = width, height = 1 },
    border = { style = "rounded", text = { top = "Arguments" } },
    win_options = { winhighlight = "Normal:Normal,FloatBorder:Normal" },
  })

  local instructions_input = Popup({
    position = "50%",
    size = { width = width, height = 20 },
    border = { style = "rounded", text = { top = "Instructions" } },
    win_options = { winhighlight = "Normal:Normal,FloatBorder:Normal", wrap = true },
    buf_options = {
      filetype = "markdown",
    },
  })

  local model_input = Popup({
    position = "50%",
    size = { width = width, height = 1 },
    border = { style = "rounded", text = { top = "Model" } },
    win_options = { winhighlight = "Normal:Normal,FloatBorder:Normal" },
  })

  -- Create layout to stack inputs vertically
  local layout_height = 29
  local layout = Layout(
    {
      position = {
        col = win_width - width,
        row = win_height - layout_height,
      },
      size = { width = width, height = layout_height },
    },
    Layout.Box({
      Layout.Box(args_input, { size = 3 }),
      Layout.Box(instructions_input, { size = 23 }),
      Layout.Box(model_input, { size = 3 }),
    }, { dir = "col" })
  )

  local function focus_and_insert(winid)
    vim.api.nvim_set_current_win(winid)
    vim.schedule(function()
      -- TODO record the previous state and of the buffer before leaving and restore to that when returning.
      vim.api.nvim_command("noautocmd startinsert")
    end)
  end

  -- Keymaps for navigation
  local function set_navigation_keymaps(input, next_input)
    input:map("i", "<Tab>", function()
      focus_and_insert(next_input.winid)
    end, { noremap = true, silent = true })
    input:map("i", "<S-Tab>", function()
      focus_and_insert(next_input.winid)
    end, { noremap = true, silent = true })
    input:map("n", "<Tab>", function()
      focus_and_insert(next_input.winid)
    end, { noremap = true, silent = true })
    input:map("n", "<S-Tab>", function()
      focus_and_insert(next_input.winid)
    end, { noremap = true, silent = true })
  end

  -- Helper function to get input value from a nui.input buffer
  local function get_input_value(input, prompt)
    local lines = vim.api.nvim_buf_get_lines(input.bufnr, 0, -1, false)
    if prompt and #lines > 0 then
      -- Remove prompt from single-line input
      return lines[1]:gsub("^" .. vim.pesc(prompt), ""):match("^%s*(.-)%s*$") or ""
    else
      return table.concat(lines, "\n")
    end
  end

  -- Keymaps for cancel
  local function set_cancel_keymaps(input)
    input:map("n", "<Esc>", function()
      -- Store inputs for next time, event when cancelling
      local args = get_input_value(args_input)
      local instructions = get_input_value(instructions_input)
      last_args = args
      last_instructions = instructions
      last_model = get_input_value(model_input)

      layout:unmount()
    end, { noremap = true, silent = true })
  end

  local function call_submit()
    -- Store inputs for next time
    local args = get_input_value(args_input)
    local instructions = get_input_value(instructions_input)
    local model = get_input_value(model_input)
    last_args = args
    last_instructions = instructions
    last_model = model

    layout:unmount()

    submit(args, instructions, model)
  end

  local function configure_input(this_input, initial_value, next_input, submit_key)
    set_navigation_keymaps(this_input, next_input)
    set_cancel_keymaps(this_input)
    args_input:map("n", "<CR>", call_submit, { noremap = true, silent = true })
    args_input:map("i", submit_key, call_submit, { noremap = true, silent = true })

    local lines = vim.split(initial_value, "\n")
    vim.api.nvim_buf_set_lines(this_input.bufnr, 0, -1, false, lines)
  end

  configure_input(args_input, last_args, instructions_input, "<CR>")
  configure_input(instructions_input, last_instructions, model_input, "<c-s>")
  configure_input(model_input, last_model, args_input, "<CR>")

  -- Mount the layout
  layout:mount()

  vim.defer_fn(function()
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

  show_rmfilter_dialog(function(args, instructions, model)
    if args == "" and instructions == "" then
      return
    end

    -- Construct and execute command
    local cmd = string.format("rmfilter --copy %s %s", vim.fn.shellescape(relative_path), args)
    if instructions ~= "" then
      cmd = cmd .. " --instructions " .. vim.fn.shellescape(instructions)
    end

    if model ~= "" then
      cmd = cmd .. " --model " .. vim.fn.shellescape(model)
    end

    -- See if any buffer has the name 'rmfilter output'
    local buf = vim.fn.bufnr("rmfilter output")
    if buf == -1 then
      -- Create a new buffer for output
      buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_name(buf, "rmfilter output")
    end

    vim.api.nvim_set_option_value("filetype", "text", { buf = buf })
    vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "Running rmfilter..." })

    -- Open the buffer in a new window
    vim.api.nvim_command("vsplit | buffer " .. buf)

    -- TODO Use plenary or open or something and stream the output to the buffer
    local output = vim.fn.system(cmd)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(output, "\n"))

    -- Set keymap to close buffer with '<Esc><Esc>'
    vim.keymap.set(
      "n",
      "<Esc><Esc>",
      ":bdelete<CR>",
      { noremap = true, silent = true, buffer = buf, desc = "Close buffer" }
    )

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

  -- Set keymap to close buffer
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
