vim.env.PRETTIERD_LOCAL_PRETTIER_ONLY = "true"

local prettier_config_files = {
  ".prettierrc",
  ".prettierrc.js",
  ".prettierrc.json",
  "prettier.config.js",
  "prettier.config.cjs",
}

local prettierd = function()
  local format_util = require("formatter.util")
  local current_path = format_util.get_current_buffer_file_path()
  local current_dir = vim.fs.dirname(current_path)
  local found_config = vim.fs.find(prettier_config_files, {
    path = current_dir,
    upward = true,
    type = "file",
    limit = 1,
  })

  local _, found = next(found_config)
  -- print(vim.inspect(found))
  if found == nil then
    return nil
  end

  local config_dirname = vim.fs.dirname(found)

  return {
    exe = "prettierd",
    args = { format_util.escape_path(current_path) },
    cwd = config_dirname,
    stdin = true,
  }
end

local black = function()
  return {
    exe = "python3",
    args = { "-m", "black", "-q", "-" },
    stdin = true,
  }
end

local ruff = function()
  local format_util = require("formatter.util")
  local current_path = format_util.get_current_buffer_file_path()
  return {
    exe = "python3",
    args = { "-m", "ruff", "format", "--stdin-filename", format_util.escape_path(current_path), "-s" },
    stdin = true,
  }
end

-- Stylua Lua formatter
function stylua()
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
function sleek()
  local format_util = require("formatter.util")
  local current_path = format_util.get_current_buffer_file_path()
  return {
    exe = "sleek",
    args = { "-i", "2" },
    stdin = true,
  }
end

-- pg_format
function pgformat()
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
function liquid_sql()
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
    opts = {
      logging = true,
      -- log_level = vim.log.levels.TRACE,
      filetype = {
        html = { prettierd },
        css = { prettierd },
        less = { prettierd },
        pcss = { prettierd },
        postcss = { prettierd },
        javascript = { prettierd },
        json = { prettierd },
        typescript = { prettierd },
        svelte = { prettierd },
        python = { ruff },
        lua = { stylua },
        sql = { pgformat },
        liquid = { liquid_sql },
      },
    },
  },
}
