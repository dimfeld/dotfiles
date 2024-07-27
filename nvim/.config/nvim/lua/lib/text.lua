local M = {}

M.starts_with = function(str, start)
  return str:sub(1, #start) == start
end

return M
