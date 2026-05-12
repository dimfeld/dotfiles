vim.env.PRETTIERD_LOCAL_PRETTIER_ONLY = "true"

local function resolve_oxfmt_exe(config_dirname)
  local local_oxfmt = config_dirname .. "/node_modules/.bin/oxfmt"
  if vim.uv.fs_stat(local_oxfmt) ~= nil then
    return local_oxfmt
  end

  return "oxfmt"
end

local function prettier_etc()
  local format_util = require("formatter.util")
  local current_path = format_util.get_current_buffer_file_path()
  local current_dir = vim.fs.dirname(current_path)

  local found_config = vim.fs.find({
    ".oxfmtrc.json",
    ".oxfmtrc.jsonc",
    "oxfmt.config.ts",
    ".prettierrc",
    ".prettierrc.js",
    ".prettierrc.json",
    "prettier.config.js",
    "prettier.config.cjs",
  }, {
    path = current_dir,
    upward = true,
    type = "file",
    limit = 1,
  })

  local _, found = next(found_config)
  if found == nil then
    return nil
  end

  local config_dirname = vim.fs.dirname(found)
  local is_oxfmt = found:find("oxfmtrc", 1, true) ~= nil or found:find("oxfmt.config.ts", 1, true) ~= nil

  if is_oxfmt then
    return {
      exe = resolve_oxfmt_exe(config_dirname),
      args = { "--stdin-filepath", format_util.escape_path(current_path) },
      cwd = config_dirname,
      stdin = true,
      no_append = true,
      ignore_exitcode = false,
    }
  end

  return {
    exe = "prettierd",
    args = { format_util.escape_path(current_path) },
    cwd = config_dirname,
    stdin = true,
    no_append = true,
    ignore_exitcode = false,
  }
end

local function black()
  return {
    exe = "python3",
    args = { "-m", "black", "-q", "-" },
    stdin = true,
  }
end

local function ruff()
  local format_util = require("formatter.util")
  local current_path = format_util.get_current_buffer_file_path()
  return {
    exe = "python3",
    args = { "-m", "ruff", "format", "--stdin-filename", format_util.escape_path(current_path), "-s" },
    stdin = true,
  }
end

-- Stylua Lua formatter
local function stylua()
  local format_util = require("formatter.util")
  return {
    exe = "stylua",
    args = {
      "--indent-type",
      "Spaces",
      "--indent-width",
      "2",
      "--search-parent-directories",
      "--stdin-filepath",
      format_util.escape_path(format_util.get_current_buffer_file_path()),
      "--",
      "-",
    },
    stdin = true,
  }
end

-- Sleek SQL formatter
local function sleek()
  local format_util = require("formatter.util")
  local current_path = format_util.get_current_buffer_file_path()
  return {
    exe = "sleek",
    args = { "-i", "2" },
    stdin = true,
  }
end

-- pg_format
local function pgformat()
  local format_util = require("formatter.util")
  local current_path = format_util.get_current_buffer_file_path()
  if current_path:find(".sql.tera") then
    return nil
  end

  return {
    exe = "pg_format --inplace  -",
    stdin = true,
  }
end

-- Format .sql.liquid files
local function liquid_sql()
  local format_util = require("formatter.util")
  local current_path = format_util.get_current_buffer_file_path()
  if current_path:find(".sql.liquid") == nil then
    return nil
  end

  -- turn this off for now
  if true then
    return nil
  end

  return pgformat()
end
return {
  {

    "mhartington/formatter.nvim",
    -- dir = "~/Documents/projects/formatter.nvim",
    opts = {
      logging = true,
      -- log_level = vim.log.levels.TRACE,
      filetype = {
        html = { prettier_etc },
        css = { prettier_etc },
        less = { prettier_etc },
        pcss = { prettier_etc },
        postcss = { prettier_etc },
        javascript = { prettier_etc },
        json = { prettier_etc },
        typescript = { prettier_etc },
        svelte = { prettier_etc },
        python = { ruff },
        lua = { stylua },
        sql = { pgformat },
        liquid = { liquid_sql },
      },
    },
  },
}
