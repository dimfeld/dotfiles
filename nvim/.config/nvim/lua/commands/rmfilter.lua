local M = {}

M.terminal_channels = {}

local ns_id = vim.api.nvim_create_namespace("rmfilter_terminal")
vim.api.nvim_create_autocmd("BufDelete", {
  group = vim.api.nvim_create_augroup("RmfilterTerminalCleanup", { clear = true }),
  callback = function(args)
    local buf = args.buf
    local chan = M.terminal_channels[buf]
    if chan then
      pcall(vim.fn.jobstop, chan) -- Stop the job if running
      M.terminal_channels[buf] = nil
    end
  end,
  desc = "Clean up terminal channel on buffer delete",
})

-- Store last used arguments
local last_args = ""
local last_instructions = ""
local last_model = "grok"

-- Helper function to setup terminal buffer and window
local function setup_terminal_buffer()
  -- See if any buffer has the name 'rmfilter'
  local buf = vim.fn.bufnr("rmfilter")
  if buf == -1 then
    -- Create a new buffer for output
    buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(buf, "rmfilter")
    vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
  end

  -- Open the buffer in a new window, if it's not currently visible
  if vim.fn.bufwinid(buf) == -1 then
    vim.api.nvim_command("vsplit | buffer " .. buf)
  end

  vim.api.nvim_set_current_win(vim.fn.bufwinid(buf))
  vim.api.nvim_command("stopinsert")

  -- Set keymap to close buffer with '<Esc><Esc>'
  vim.keymap.set(
    { "n", "t" },
    "<Esc><Esc>",
    ":bdelete!<CR>",
    { noremap = true, silent = true, buffer = buf, desc = "Close buffer" }
  )

  local chan = M.terminal_channels[buf]
  if chan then
    pcall(vim.fn.jobstop, chan) -- Stop any existing job
    M.terminal_channels[buf] = nil
  end

  return buf
end

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
    input:map("n", "<Tab>", function()
      focus_and_insert(next_input.winid)
    end, { noremap = true, silent = true })

    -- Reverse mappings, set S-Tab on next_input to go to this input
    next_input:map("i", "<S-Tab>", function()
      focus_and_insert(input.winid)
    end, { noremap = true, silent = true })
    next_input:map("n", "<S-Tab>", function()
      focus_and_insert(input.winid)
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
    this_input:map("n", "<CR>", call_submit, { noremap = true, silent = true })
    this_input:map("i", submit_key, call_submit, { noremap = true, silent = true })

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
  local absolute_path = vim.fn.resolve(vim.fn.fnamemodify(bufname, ":p"))
  local buffer_dir = bufname ~= "" and vim.fn.fnamemodify(absolute_path, ":h")
  local filename = bufname ~= "" and vim.fn.fnamemodify(bufname, ":t") or ""

  show_rmfilter_dialog(function(args, instructions, model)
    if args == "" and instructions == "" then
      return
    end

    -- Store current working directory
    local original_cwd = vim.fn.getcwd()

    -- Construct command
    local cmd = string.format("rmfilter --copy %s %s", filename ~= "" and vim.fn.shellescape(filename) or "", args)
    if instructions ~= "" then
      cmd = cmd .. " --instructions " .. vim.fn.shellescape(instructions)
    end
    if model ~= "" then
      cmd = cmd .. " --model " .. vim.fn.shellescape(model)
    end

    -- Setup terminal buffer
    local buf = setup_terminal_buffer()
    local term_chan = vim.api.nvim_open_term(buf, {})

    -- Execute command with error handling
    local success, error_msg
    if buffer_dir ~= "" then
      -- Change to buffer's directory
      vim.fn.chdir(buffer_dir)
    end
    success, error_msg = pcall(function()
      chan = vim.fn.jobstart(cmd, {
        on_stdout = function(_, data)
          if data then
            vim.api.nvim_chan_send(term_chan, table.concat(data, "\n") .. "\n")
          end
        end,
        on_stderr = function(_, data)
          if data then
            vim.api.nvim_chan_send(term_chan, table.concat(data, "\n") .. "\n")
          end
        end,
        on_exit = function(_, code)
          M.terminal_channels[buf] = nil -- Clean up on exit
          vim.api.nvim_chan_send(term_chan, code == 0 and "rmfilter executed\n" or "rmfilter failed\n")
          vim.notify(
            code == 0 and "rmfilter executed: " .. cmd or "rmfilter failed: " .. cmd,
            code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR
          )
        end,
        pty = true, -- Enable ANSI code processing
      })

      if chan <= 0 then
        error("Failed to start job for command: " .. cmd)
      end

      M.terminal_channels[buf] = chan
    end)
    if buffer_dir ~= "" then
      -- restore original working directory
      vim.fn.chdir(original_cwd)
    end

    if not success then
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "Error running rmfilter: " .. error_msg })
      vim.notify("rmfilter error: " .. error_msg, vim.log.levels.ERROR)
    end
  end)
end

function M.apply_edits()
  -- Get current buffer's directory
  local bufname = vim.api.nvim_buf_get_name(0)
  local absolute_path = vim.fn.resolve(vim.fn.fnamemodify(bufname, ":p"))
  local buffer_dir = vim.fn.fnamemodify(absolute_path, ":h")

  -- Store current working directory
  local original_cwd = vim.fn.getcwd()

  -- Setup terminal buffer
  local buf = setup_terminal_buffer()

  -- Create terminal channel
  local term_chan = vim.api.nvim_open_term(buf, {})

  -- Execute command with error handling
  local success, error_msg
  vim.fn.chdir(buffer_dir) -- Change to buffer's directory
  success, error_msg = pcall(function()
    local chan = vim.fn.jobstart("apply-llm-edits", {
      on_stdout = function(_, data)
        if data then
          vim.api.nvim_chan_send(term_chan, table.concat(data, "\n") .. "\n")
        end
      end,
      on_stderr = function(_, data)
        if data then
          vim.api.nvim_chan_send(term_chan, table.concat(data, "\n") .. "\n")
        end
      end,
      on_exit = function(_, code)
        M.terminal_channels[buf] = nil -- Clean up on exit
        vim.api.nvim_chan_send(term_chan, code == 0 and "apply-llm-edits executed\n" or "apply-llm-edits failed\n")
        if code == 0 then
          -- Get repository root
          local repo_root = require("lib.git").git_repo_toplevel()
          if repo_root then
            -- Parse output for unique filenames (format: "Applying diff to ${filename} ...")
            local seen_filenames = {}
            local unique_filenames = {}
            for _, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
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
          vim.notify("apply-llm-edits executed", vim.log.levels.INFO)
        else
          vim.notify("apply-llm-edits failed", vim.log.levels.ERROR)
        end
      end,
      pty = true, -- Enable ANSI code processing
    })

    if chan <= 0 then
      error("Failed to start job for command: apply-llm-edits")
    end

    M.terminal_channels[buf] = chan
  end)
  vim.fn.chdir(original_cwd) -- Always restore original working directory

  if not success then
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "Error running apply-llm-edits: " .. error_msg })
    vim.notify("apply-llm-edits error: " .. error_msg, vim.log.levels.ERROR)
  end
end

return M
