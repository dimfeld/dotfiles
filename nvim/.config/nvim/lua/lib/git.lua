local M = {}

local git_repo_cache = {}

--- @param path string
--- @return string
local function normalize_path(path)
  return vim.fn.fnamemodify(path, ":p"):gsub("/$", "")
end

--- @param path string|nil
--- @return string
local function repo_search_dir(path)
  if path and path ~= "" then
    return normalize_path(vim.fn.fnamemodify(path, ":h"))
  end

  return normalize_path(vim.fn.getcwd())
end

--- @param path string|nil
--- @return { root: string, vcs: "jj"|"git"|nil }
M.repo_info = function(path)
  local dir = repo_search_dir(path)

  local jj_dir = vim.fn.finddir(".jj", dir .. ";")
  if jj_dir ~= "" then
    return {
      root = normalize_path(dir .. "/" .. jj_dir .. "/.."),
      vcs = "jj",
    }
  end

  local git_result = vim.system({ "git", "-C", dir, "rev-parse", "--show-toplevel" }, { text = true }):wait()
  local git_root = vim.fn.trim(git_result.stdout or "")
  if git_result.code == 0 and git_root ~= "" then
    return {
      root = normalize_path(git_root),
      vcs = "git",
    }
  end

  return {
    root = "",
    vcs = nil,
  }
end

--- @param path string
--- @return string|nil
M.repo_relative_path = function(path)
  local abs_path = normalize_path(path)
  local repo = M.repo_info(abs_path)
  if repo.root == "" then
    return nil
  end

  local prefix = repo.root .. "/"
  if vim.startswith(abs_path, prefix) then
    return abs_path:sub(#prefix + 1)
  end

  return nil
end

-- Return the top level directory of the current git repo
--- @return string
M.git_repo_toplevel = function()
  local cwd = vim.fn.getcwd()
  local cached = git_repo_cache[cwd]
  if cached ~= nil then
    return cached
  end

  local top_level = M.repo_info().root

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
