-- Spinner for progress indication
local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
local next_idx = 1
local timer_by_idx = {}

function tick_spinner(idx)
  local data = timer_by_idx[idx]
  if not data then
    return
  end

  local noti = vim.notify(spinner[data.spinner_idx] .. " " .. data.message, vim.log.levels.INFO, {
    replace = data.notification,
    title = data.title,
    timeout = 500,
  })

  data.notification = noti
  data.spinner_idx = (data.spinner_idx % #spinner) + 1

  vim.defer_fn(function()
    tick_spinner(idx)
  end, 100)
end

-- Function to start the spinner
local function start_spinner(title, message)
  local timer_idx = next_idx
  next_idx = next_idx + 1

  timer_by_idx[timer_idx] = {
    title = title,
    message = message,
    notification = notification,
    spinner_idx = 1,
  }
  tick_spinner(timer_idx)

  return timer_idx
end

-- Function to stop the spinner
local function stop_spinner(idx, end_message, level)
  local data = timer_by_idx[idx]
  table.remove(timer_by_idx, idx)
  print(vim.inspect(data))
  if data then
    if end_message then
      vim.notify(end_message, level or vim.log.levels.INFO, {
        title = data.title,
        replace = data.notification,
      })
    end
  end
end

-- Stop all spinners in case of bugs
local function stop_all()
  timer_by_idx = {}
end

return {
  start = start_spinner,
  stop = stop_spinner,
  stop_all,
}
