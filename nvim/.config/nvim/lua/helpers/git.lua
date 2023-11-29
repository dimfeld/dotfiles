local M = {}

local git_repo_cache = {}

-- Return the top level directory of the current git repo
M.git_repo_toplevel = function()
  local cwd = vim.fn.getcwd()
  local cached = git_repo_cache[cwd]
  if cached ~= nil then
    return cached
  end

  top_level = vim.fn.trim(vim.fn.system("git rev-parse --show-toplevel"))
  git_repo_cache[cwd] = top_level
  return top_level
end

return M
