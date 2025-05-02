-- Status line configuration
local cmdbar = require("config.telescope_commandbar")

local status_filename = {
  "filename",
  file_status = true,
  shorten = false,
  path = 1, -- relative path
}

local status_diagnostics = {
  "diagnostics",
  sources = { "nvim_lsp" },
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

local function isRecording()
  local reg = vim.fn.reg_recording()
  if reg == "" then
    return ""
  end -- not recording
  return "recording " .. reg
end

local function codeium_or_searchcount()
  if vim.fn.mode() == "i" then
    -- In insert mode, show Codeium status
    local worked, virttext = pcall(require, "codeium.virtual_text")
    if worked then
      return virttext.status_string()
    else
      return ""
    end
  else
    -- In other modes, show search count
    if vim.v.hlsearch == 0 then
      return ""
    end

    local ok, result = pcall(vim.fn.searchcount, { maxcount = 999, timeout = 500 })
    if not ok or next(result) == nil then
      return ""
    end

    local denominator = math.min(result.total, result.maxcount)
    return string.format("[%d/%d]", result.current, denominator)
  end
end

return {
  -- Enable git changes to be shown in sign column
  { "airblade/vim-gitgutter", cond = false, event = "VeryLazy" },
  {
    "lewis6991/gitsigns.nvim",
    cond = not vim.g.vscode,
    event = "VeryLazy",
    opts = {
      word_diff = false,
      signcolumn = false,
      numhl = false,
      current_line_blame_opts = {
        delay = 250,
      },
      on_attach = function(bufnr)
        local gitsigns = require("gitsigns")

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        map("n", "]c", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            gitsigns.nav_hunk("next")
          end
        end)

        map("n", "[c", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            gitsigns.nav_hunk("prev")
          end
        end)

        map("n", "<leader>hs", gitsigns.stage_hunk)
        map("n", "<leader>hr", gitsigns.reset_hunk)
        map("v", "<leader>hs", function()
          gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end)
        map("v", "<leader>hr", function()
          gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end)
        map("n", "<leader>hS", gitsigns.stage_buffer)
        map("n", "<leader>hu", gitsigns.undo_stage_hunk)
        map("n", "<leader>hp", gitsigns.preview_hunk)
        map("n", "<leader>hb", function()
          gitsigns.blame_line({ full = true })
        end)
        map("n", "<leader>hd", gitsigns.diffthis)
        map("n", "<leader>hD", function()
          gitsigns.diffthis("~")
        end)
      end,
    },
    config = function(_, opts)
      require("gitsigns").setup(opts)
      cmdbar.add_commands({
        {
          name = "Toggle Intra-word Diff",
          category = "Git",
          action = function()
            vim.cmd("Gitsigns toggle_word_diff")
          end,
        },
        -- {
        --   name = "Toggle Git Line Highlighting",
        --   category = "Git",
        --   action = function()
        --     vim.cmd("Gitsigns toggle_linehl")
        --   end,
        -- },
        {
          name = "Toggle Current Line Blame",
          category = "Git",
          action = function()
            vim.cmd("Gitsigns toggle_current_line_blame")
          end,
        },
      })
    end,
  },
  {
    "echasnovski/mini.diff",
    version = "*",
    opts = {
      view = {
        style = "number",
      },
      mappings = {
        -- Disable all mappings since we use other plugins for it
        apply = "",
        reset = "",
        textobject = "",
        goto_first = "",
        goto_last = "",
        goto_next = "",
        goto_prev = "",
      },
    },
    config = function(_, opts)
      require("mini.diff").setup(opts)
      cmdbar.add_commands({
        {
          name = "Toggle Git Diff Overlay",
          category = "Git",
          action = function()
            MiniDiff.toggle_overlay()
          end,
        },
      })
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    cond = not vim.g.vscode,
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
        lualine_c = { status_filename, isRecording },
        lualine_x = { "filetype" },
        lualine_y = { status_diagnostics, lualine_get_words },
        lualine_z = { codeium_or_searchcount, "progress", "location" },
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

  -- UI toolkit
  "MunifTanjim/nui.nvim",

  -- Nicer notifications
  {
    "folke/noice.nvim",
    cond = not vim.g.vscode,
    event = "VeryLazy",
    -- stylua: ignore
    keys = {
      { "<leader>sn", "", desc = "+noice"},
      { "<S-Enter>", function() require("noice").redirect(vim.fn.getcmdline()) end, mode = "c", desc = "Redirect Cmdline" },
      { "<leader>snl", function() require("noice").cmd("last") end, desc = "Noice Last Message" },
      { "<leader>snh", function() require("noice").cmd("history") end, desc = "Noice History" },
      { "<leader>sna", function() require("noice").cmd("all") end, desc = "Noice All" },
      { "<leader>snd", function() require("noice").cmd("dismiss") end, desc = "Dismiss All" },
      { "<leader>snt", function() require("noice").cmd("pick") end, desc = "Noice Picker (Telescope/FzfLua)" },
    },
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
        {
          view = "mini",
          filter = {
            event = "msg_show",
            any = {
              { find = "%d+L, %d+B" },
              { find = "; after #%d+" },
              { find = "; before #%d+" },
              { find = "No more valid diagnostics" },
              { find = "[nvim-treesitter]" },
            },
          },
        },
        {
          view = "mini",
          filter = {
            error = true,
            find = "completion request failed",
          },
        },
        {
          opts = { skip = true },
          filter = {
            kind = { "debug" },
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
        hover = {
          enabled = true,
          silent = true,
        },
        signature = {
          enabled = true,
          auto_open = {
            enabled = true,
            trigger = true, -- Automatically show signature help when typing a trigger character from the LSP
            -- luasnip = true, -- Will open signature help when jumping to Luasnip insert nodes
            throttle = 50, -- Debounce lsp signature help request by 50ms
          },
          view = nil, -- when nil, use defaults from documentation
          ---@type NoiceViewOptions
          opts = {}, -- merged with defaults from documentation
        },
        message = {
          -- Messages shown by lsp servers
          enabled = true,
          view = "notify",
          opts = {},
        },
        -- defaults for hover and signature help
        documentation = {
          view = "hover",
          ---@type NoiceViewOptions
          opts = {
            lang = "markdown",
            replace = true,
            render = "plain",
            format = { "{message}" },
            win_options = { concealcursor = "n", conceallevel = 3 },
          },
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
    },
  },

  -- Nicer replacement for builtin input and select
  {
    "stevearc/dressing.nvim",
    cond = not vim.g.vscode,
    dependencies = { "nvim-telescope/telescope.nvim" },
    event = "VeryLazy",
    opts = {
      -- Using noice for input
      input = { enabled = false },
    },
  },
}
