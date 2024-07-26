-- Status line configuration

local status_filename = {
  "filename",
  file_status = true,
  shorten = false,
  path = 1, -- relative path
}

local status_diagnostics = {
  "diagnostics",
  sources = { "coc" },
  sections = { "error", "warn" },
}

local get_words_filetypes = {
  markdown = true,
  text = true,
  md = true,
  asciidoc = true,
  adoc = true,
}
local function lualine_get_words()
  local filetype = vim.bo.filetype
  if get_words_filetypes[filetype] == nil then
    return ""
  end

  local words = vim.fn.wordcount().words
  if words == 1 then
    return "1 word"
  else
    return string.format("%d words", words)
  end
end

return {
  -- Enable git changes to be shown in sign column
  { "airblade/vim-gitgutter", event = "VeryLazy" },

  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        icons_enabled = true,
        theme = "codedark",
        component_separators = {
          left = "",
          right = "",
        },
        section_separators = {
          left = "",
          right = "",
        },
        disabled_filetypes = {},
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = {
          {
            "branch",
            fmt = function(str)
              return str:sub(1, 16)
            end,
          },
        },
        lualine_c = { status_filename },
        lualine_x = {
          {
            require("noice").api.status.message.get_hl,
            cond = require("noice").api.status.message.has,
          },
          "filetype",
        },
        lualine_y = { status_diagnostics, lualine_get_words },
        lualine_z = { "searchcount", "progress", "location" },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { status_filename },
        lualine_x = { "filetype" },
        lualine_y = { lualine_get_words },
        lualine_z = { "location" },
      },
    },
  },

  -- Better `vim.notify()`
  {
    "rcarriga/nvim-notify",
    keys = {
      {
        "<leader>un",
        function()
          require("notify").dismiss({ silent = true, pending = true })
        end,
        desc = "Dismiss All Notifications",
      },
    },
    opts = {
      stages = "static",
      top_down = false,
      timeout = 5000,
      max_height = function()
        return math.floor(vim.o.lines * 0.75)
      end,
      max_width = function()
        return math.floor(vim.o.columns * 0.75)
      end,
      on_open = function(win)
        vim.api.nvim_win_set_config(win, { zindex = 100 })
      end,
    },
    init = function()
      -- Skip this since we're using noice on top of nvim-notify
      -- vim.notify = require("notify")
    end,
  },

  -- Nicer notifications
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      routes = {
        -- Hide messages when search fails to find a result
        {
          opts = { skip = true },
          filter = {
            any = {
              {
                error = true,
                find = "E486: Pattern not found",
              },
              {
                event = "msg_show",
                cond = function(msg)
                  return msg:content():sub(1, 1) == "/"
                end,
              },
            },
          },
        },
      },
      lsp = {
        -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
        },
      },
      messages = {
        view_search = false,
      },
      cmdline = {
        view = "cmdline_popup",
      },
      views = {
        cmdline = {
          win_options = {
            winblend = 0,
          },
        },
        cmdline_popup = {
          position = {
            row = "95%",
            col = "50%",
          },
          size = {
            width = "90%",
          },
          win_options = {
            winblend = 0,
          },
        },
        cmdline_popupmenu = {
          position = {
            row = "90%",
            col = "50%",
          },
          size = {
            width = "90%",
          },
          anchor = "NW",
        },
      },
      -- you can enable a preset for easier configuration
      presets = {
        bottom_search = true, -- use a classic bottom cmdline for search
        command_palette = true, -- position the cmdline and popupmenu together
        long_message_to_split = true, -- long messages will be sent to a split
        inc_rename = false, -- enables an input dialog for inc-rename.nvim
        lsp_doc_border = false, -- add a border to hover docs and signature help
      },
    },
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
  },

  -- Nicer replacement for builtin input and select
  {
    "stevearc/dressing.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    -- Disabled in favor of noice
    enabled = false,
    event = "VeryLazy",
    opts = {},
  },
}
