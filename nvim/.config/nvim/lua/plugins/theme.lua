local function setup_arctic()
  local auGroup = vim.api.nvim_create_augroup("ArcticTheme", {})

  vim.api.nvim_create_autocmd("ColorScheme", {
    group = auGroup,
    pattern = "arctic",
    callback = function()
      vim.cmd([[
      " Make background transparent for many things
      hi Normal ctermbg=NONE guibg=NONE
      " hi NonText ctermbg=NONE guibg=NONE
      " hi LineNr ctermfg=NONE guibg=NONE
      " hi SignColumn ctermfg=NONE guibg=NONE

      " Darker end of buffer. No need to set it apart when line numbers are enabled.
      hi EndOfBuffer ctermbg=NONE ctermfg=NONE guibg=#101010 guifg=#101010

      " Hide characters in line between panes
      hi VertSplit gui=NONE guifg=#101010 guibg=#101010
      hi clear WinSeparator
      hi link WinSeparator VertSplit

      hi InlayHint ctermfg=73 ctermbg=235 guifg=#999999 guibg=#222222

      hi Search guibg=#825335
      " Light pink for codeium/copilot. Easy to read but also clearly not part of the existing text
      hi CodeiumSuggestion guifg=#eeaaaa ctermfg=10
      hi CopilotSuggestion guifg=#eeaaaa ctermfg=10

      " Tone down Treesitter styles a bit.
      hi @variable guifg=None
      hi @variable.member guifg=None
      hi! link @module PreProc
      hi! link @type Normal
    ]])
    end,
  })

  vim.cmd([[ colorscheme arctic ]])
end

return {
  {
    "f-person/auto-dark-mode.nvim",
    enabled = false,
    opts = {},
  },
  {
    "kyazdani42/nvim-web-devicons",
    event = "VeryLazy",
  },

  {
    "rockyzhang24/arctic.nvim",
    dependencies = { "rktjmp/lush.nvim" },
    branch = "v2",
    priority = 1000,
    config = setup_arctic,
  },

  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    enabled = false,
    -- cond = theme == "catppuccin",
    -- config = setup_catppuccin,
    opts = {
      flavour = "mocha",
      color_overrides = {
        mocha = {
          base = "#101010",
          mantle = "#101010",
          crust = "#101010",
        },
      },
      integrations = {
        cmp = true,
        treesitter = true,
        notify = true,
        gitsigns = true,
        leap = true,
        markdown = true,
        noice = true,
        render_markdown = true,
        telescope = {
          enabled = true,
        },
        native_lsp = {
          enabled = true,
          virtual_text = {
            errors = { "italic" },
            hints = { "italic" },
            warnings = { "italic" },
            information = { "italic" },
            ok = { "italic" },
          },
          underlines = {
            errors = { "underline" },
            hints = { "underline" },
            warnings = { "underline" },
            information = { "underline" },
            ok = { "underline" },
          },
          inlay_hints = {
            background = true,
          },
        },
      },
      custom_highlights = function(colors)
        return {
          CodeiumSuggestion = { fg = colors.pink },
        }
      end,
    },
  },
}
