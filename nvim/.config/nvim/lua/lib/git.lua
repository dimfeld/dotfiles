local M = {}

local git_repo_cache = {}

-- Return the top level directory of the current git repo
--- @return string
M.git_repo_toplevel = function()
  local cwd = vim.fn.getcwd()
  local cached = git_repo_cache[cwd]
  if cached ~= nil then
    return cached
  end

  local top_level = vim.fn.trim(vim.fn.system("git rev-parse --show-toplevel"))
  git_repo_cache[cwd] = top_level
  return top_level
end

-- Return the default branch of the current git repo, assuming it's either master or main
--- @return string|nil
M.find_default_branch = function()
  -- Get all branches (both local and remote)
  local branches = vim.fn.system("git branch -a"):gsub("%s+", " ")

  -- Check for master or main (both local and remote)
  local patterns = {
    "^master$",
    "^main$",
    "origin/master$",
    "origin/main$",
  }

  for _, pattern in ipairs(patterns) do
    for branch in branches:gmatch("[%s]([^%s]+)") do
      if branch:match(pattern) then
        -- Remove 'origin/' prefix if present
        local retval, _ = branch:gsub("^origin/", "")
        return retval
      end
    end
  end

  return nil
end

return M
