-- Spinner for progress indication
local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
local spinner_idx = 1
local timer = nil

-- Function to start the spinner
local function start_spinner(message)
  spinner_idx = 1
  timer = vim.loop.new_timer()
  timer:start(
    0,
    100,
    vim.schedule_wrap(function()
      vim.api.nvim_echo({ { spinner[spinner_idx] .. " " .. message, "None" } }, false, {})
      spinner_idx = (spinner_idx % #spinner) + 1
    end)
  )
end

-- Function to stop the spinner
local function stop_spinner(preserve)
  if timer then
    timer:stop()
    timer:close()
    timer = nil
    if not preserve then
      vim.schedule(function()
        vim.api.nvim_echo({ { "", "None" } }, false, {})
      end)
    end
  end
end

return {
  start = start_spinner,
  stop = stop_spinner,
}
