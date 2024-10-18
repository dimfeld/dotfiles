local function get_floating_preview_window()
  for _, winid in pairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_get_config(winid).zindex then
      return winid
    end
  end
end

local function toggle_signature_help()
  local floating_preview_window = get_floating_preview_window()
  if floating_preview_window then
    vim.api.nvim_win_close(floating_preview_window, true)
  else
    vim.lsp.buf.signature_help()
  end
end

local function configure_lsp_keymaps()
  vim.keymap.set("i", "<C-K>", toggle_signature_help, {})

  -- Go to definition
  vim.keymap.set("n", "<leader>dd", vim.lsp.buf.definition, { silent = true, desc = "Go to definition" })

  -- Go to implementation
  vim.keymap.set("n", "<leader>dj", vim.lsp.buf.implementation, { silent = true, desc = "Go to implementation" })

  -- Show diagnostic information
  vim.keymap.set("n", "<leader>dg", vim.diagnostic.open_float, { silent = true, desc = "Show diagnostic info" })

  -- Rename symbol
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { silent = true, desc = "Rename symbol" })

  -- Navigate diagnostics
  vim.keymap.set("n", "[G", vim.diagnostic.goto_prev, { silent = true, desc = "Previous diagnostic" })
  vim.keymap.set("n", "]G", vim.diagnostic.goto_next, { silent = true, desc = "Next diagnostic" })

  -- Navigate errors
  vim.keymap.set("n", "[g", function()
    vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })
  end, { silent = true, desc = "Previous error" })
  vim.keymap.set("n", "]g", function()
    vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
  end, { silent = true, desc = "Next error" })

  -- Code actions
  vim.keymap.set("n", "<leader>al", function()
    local cursor = vim.fn.getpos(".")
    vim.lsp.buf.code_action({
      range = {
        start = { cursor[2], 0 },
        ["end"] = { cursor[2], 1000 },
      },
    })
  end, { silent = true, desc = "Code action on line" })

  vim.keymap.set("n", "<leader>ac", function()
    vim.lsp.buf.code_action()
  end, { silent = true, desc = "Code action at cursor" })
end

local function configure_lsp_servers()
  -- local capabilities = vim.lsp.protocol.make_client_capabilities()
  -- capabilities.textDocument.completion.completionItem.snippetSupport = true
  local lspconfig = require("lspconfig")
  lspconfig.cssls.setup({})
  lspconfig.eslint.setup({})
  lspconfig.gopls.setup({})
  lspconfig.html.setup({})
  lspconfig.jsonls.setup({})
  lspconfig.lua_ls.setup({})
  lspconfig.pyright.setup({})
  lspconfig.rust_analyzer.setup({})
  lspconfig.svelte.setup({})
  lspconfig.tailwindcss.setup({})
  lspconfig.terraformls.setup({})
  lspconfig.ts_ls.setup({
    init_options = {
      plugins = {
        {
          name = "typescript-svelte-plugin",
          location = vim.fn.expand("$HOME/.pnpm/5/node_modules/typescript-svelte-plugin"),
          languages = { "javascript", "typescript" },
        },
      },
    },
    filetypes = {
      "javascript",
      "typescript",
      "svelte",
    },
  })
  lspconfig.yamlls.setup({})
end

return {
  {
    "neovim/nvim-lspconfig",
    opts = {},
    config = function(_, opts)
      configure_lsp_keymaps()
      configure_lsp_servers()
    end,
  },

  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-path",
      "onsails/lspkind-nvim",
    },
    opts = {},
    config = function(_, opts)
      local cmp = require("cmp")
      cmp.setup({
        snippet = {
          expand = function(args)
            vim.snippet.expand(args.body)
          end,
        },
        formatting = {
          format = require("lspkind").cmp_format({
            mode = "symbol", -- show only symbol annotations
            maxwidth = 50, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
            -- can also be a function to dynamically calculate max width such as
            -- maxwidth = function() return math.floor(0.45 * vim.o.columns) end,
            ellipsis_char = "...", -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
            show_labelDetails = true, -- show labelDetails in menu. Disabled by default

            -- The function below will be called before any actual modifications from lspkind
            -- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
            -- before = function (entry, vim_item)
            --
            --   return vim_item
            -- end
          }),
        },
        preselect = cmp.PreselectMode.None,
        mapping = {
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          -- Open completion menu
          ["<C-Space>"] = cmp.mapping.complete(),
          -- Accept and perform an autoimport if one is available
          ["<leader>c"] = cmp.mapping.confirm(),
          ["<C-e>"] = cmp.mapping.abort(),
          -- Close and perform the arrow movement
          ["<Up>"] = function(fallback)
            cmp.abort()
            fallback()
          end,
          ["<Down>"] = function(fallback)
            cmp.abort()
            fallback()
          end,
          ["<Left>"] = function(fallback)
            cmp.abort()
            fallback()
          end,
          ["<Right>"] = function(fallback)
            cmp.abort()
            fallback()
          end,
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            else
              fallback()
            end
          end, { "i", "s" }),
        },
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
        }, {
          { name = "path" },
          { name = "buffer" },
        }),
      })
    end,
  },
  {
    -- This is supposed to improve the UI of the calls below. Haven't tried it yet.
    "RishabhRD/nvim-lsputils",
    enabled = true,
    dependencies = {
      "RishabhRD/popfix",
    },
    opts = {},
    config = function(_, opts)
      vim.lsp.handlers["textDocument/codeAction"] = require("lsputil.codeAction").code_action_handler
      vim.lsp.handlers["textDocument/references"] = require("lsputil.locations").references_handler
      vim.lsp.handlers["textDocument/definition"] = require("lsputil.locations").definition_handler
      vim.lsp.handlers["textDocument/declaration"] = require("lsputil.locations").declaration_handler
      vim.lsp.handlers["textDocument/typeDefinition"] = require("lsputil.locations").typeDefinition_handler
      vim.lsp.handlers["textDocument/implementation"] = require("lsputil.locations").implementation_handler
      vim.lsp.handlers["textDocument/documentSymbol"] = require("lsputil.symbols").document_handler
      vim.lsp.handlers["workspace/symbol"] = require("lsputil.symbols").workspace_handler
    end,
  },
  -- "nvim-lua/lsp-status.nvim",
}
