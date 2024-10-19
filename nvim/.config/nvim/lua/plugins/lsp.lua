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
  local ts_server_settings = {
    inlayHints = {
      includeInlayParameterNameHints = "all", -- 'none' | 'literals' | 'all'
      includeInlayParameterNameHintsWhenArgumentMatchesName = false,
      includeInlayVariableTypeHints = false,
      includeInlayFunctionParameterTypeHints = false,
      includeInlayVariableTypeHintsWhenTypeMatchesName = false,
      includeInlayPropertyDeclarationTypeHints = false,
      includeInlayFunctionLikeReturnTypeHints = false,
      includeInlayEnumMemberValueHints = true,
    },
    preferences = {
      importModuleSpecifierEnding = "js",
      importModuleSpecifierPreference = "shortest",
    },
  }

  -- local capabilities = vim.lsp.protocol.make_client_capabilities()
  -- capabilities.textDocument.completion.completionItem.snippetSupport = true
  local lspconfig = require("lspconfig")
  lspconfig.cssls.setup({})
  lspconfig.eslint.setup({})
  lspconfig.gopls.setup({})
  lspconfig.html.setup({})
  lspconfig.jsonls.setup({})
  lspconfig.lua_ls.setup({
    settings = {
      Lua = {
        runtime = {
          version = "LuaJIT",
        },
        diagnostics = {
          globals = { "vim" },
        },
        workspace = {
          library = { vim.fn.expand("$VIMRUNTIME/lua"), vim.fn.expand("$VIMRUNTIME/lua/vim/lsp") },
          checkThirdParty = false,
        },
        telemetry = {
          enable = false,
        },
      },
    },
  })
  lspconfig.pyright.setup({
    settings = {
      pyright = {
        inlayHints = {
          parameterTypes = false,
        },
      },
    },
  })
  lspconfig.rust_analyzer.setup({
    settings = {
      ["rust-analyzer"] = {
        rustFmt = {
          extraArgs = {
            "+nightly",
          },
        },
      },
    },
  })
  lspconfig.svelte.setup({
    settings = {
      typescript = ts_server_settings,
      javascript = ts_server_settings,
    },
  })
  lspconfig.tailwindcss.setup({})
  lspconfig.terraformls.setup({})
  lspconfig.ts_ls.setup({
    settings = {
      typescript = ts_server_settings,
      javascript = ts_server_settings,
    },
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
    },
  })
  lspconfig.yamlls.setup({})
end

local function on_attach(buffer, client)
  if not client or not vim.api.nvim_buf_is_valid(buffer) then
    return
  end

  if not vim.bo[buffer].buflisted then
    return
  end
  -- don't trigger on nofile buffers
  if vim.bo[buffer].buftype == "nofile" then
    return
  end

  if client.supports_method("textDocument/inlayHint") or client.server_capabilities.inlayHintProvider then
    vim.lsp.inlay_hint.enable(true)
  end

  vim.lsp.codelens.refresh()

  local augroup = vim.api.nvim_create_augroup("MyLspAttached", {})

  vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
    buffer = buffer,
    group = augroup,
    callback = vim.lsp.codelens.refresh,
  })

  -- vim.api.nvim_create_autocmd("CursorHold", {
  --   buffer = buffer,
  --   group = augroup,
  --   callback = function()
  --     vim.diagnostic.open_float()
  --   end,
  -- })
end

local function configure_lsp_attach()
  local augroup = vim.api.nvim_create_augroup("MyLspAttach", { clear = true })

  vim.api.nvim_create_autocmd("User", {
    pattern = "LspDynamicCapability",
    group = augroup,
    callback = on_attach,
  })

  vim.api.nvim_create_autocmd("LspAttach", {
    group = augroup,
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      on_attach(args.buf, client)
    end,
  })

  local register_capability = vim.lsp.handlers["client/registerCapability"]
  vim.lsp.handlers["client/registerCapability"] = function(err, res, ctx)
    ---@diagnostic disable-next-line: no-unknown
    local ret = register_capability(err, res, ctx)
    local client = vim.lsp.get_client_by_id(ctx.client_id)
    if client then
      for buffer in pairs(client.attached_buffers) do
        on_attach(buffer, client)
      end
    end
    return ret
  end
end

return {
  {
    "neovim/nvim-lspconfig",
    opts = {},
    config = function(_, opts)
      configure_lsp_attach()
      configure_lsp_keymaps()
      configure_lsp_servers()

      vim.diagnostic.config({
        virtual_text = {
          severity = { vim.diagnostic.severity.ERROR, vim.diagnostic.severity.WARN },
        },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "•",
            [vim.diagnostic.severity.WARN] = "•",
            [vim.diagnostic.severity.INFO] = "•",
            [vim.diagnostic.severity.HINT] = "•",
          },
        },
        float = {
          severity_sort = true,
          source = true,
        },
        jump = {
          float = true,
        },
        severity_sort = true,
      })
    end,
  },

  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
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

      -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" },
        },
        view = {
          entries = {
            selection_order = "near_cursor",
          },
        },
      })

      -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" },
        }, {
          { name = "cmdline" },
        }),
        view = {
          entries = {
            selection_order = "near_cursor",
          },
        },
        matching = { disallow_symbol_nonprefix_matching = false },
      })
    end,
  },
}
