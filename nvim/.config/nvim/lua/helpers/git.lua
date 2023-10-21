local M = {}

-- Return the top level directory of the current git repo
M.git_repo_toplevel = function()
  return vim.fn.trim(vim.fn.system("git rev-parse --show-toplevel"))
end

return M
