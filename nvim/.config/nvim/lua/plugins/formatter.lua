vim.env.PRETTIERD_LOCAL_PRETTIER_ONLY = "true"

local prettier_config_files = {
  ".prettierrc",
  ".prettierrc.js",
  ".prettierrc.json",
  "prettier.config.js",
  "prettier.config.cjs",
}

local oxfmt_config_files = {
  ".oxfmtrc.json",
  ".oxfmtrc.jsonc",
  "oxfmt.config.ts",
}

local function find_config_file(config_files, current_dir)
  local found_config = vim.fs.find(config_files, {
    path = current_dir,
    upward = true,
    type = "file",
    limit = 1,
  })

  local _, found = next(found_config)
  return found
end

local function prettier_etc()
  local format_util = require("formatter.util")
  local current_path = format_util.get_current_buffer_file_path()
  local current_dir = vim.fs.dirname(current_path)

  local oxfmt_config = find_config_file(oxfmt_config_files, current_dir)
  if oxfmt_config ~= nil then
    local config_dirname = vim.fs.dirname(oxfmt_config)

    return {
      exe = "oxfmt",
      args = { "--stdin-filepath", format_util.escape_path(current_path) },
      cwd = config_dirname,
      stdin = true,
      no_append = true,
      ignore_exitcode = false,
    }
  end

  local found = find_config_file(prettier_config_files, current_dir)
  if found == nil then
    return nil
  end

  local config_dirname = vim.fs.dirname(found)

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
