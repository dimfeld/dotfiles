local function configure_lsp_servers()
  local ts_server_settings = {
    -- inlayHints = {
    --   includeInlayParameterNameHints = "all", -- 'none' | 'literals' | 'all'
    --   includeInlayParameterNameHintsWhenArgumentMatchesName = false,
    --   includeInlayVariableTypeHints = false,
    --   includeInlayFunctionParameterTypeHints = false,
    --   includeInlayVariableTypeHintsWhenTypeMatchesName = false,
    --   includeInlayPropertyDeclarationTypeHints = false,
    --   includeInlayFunctionLikeReturnTypeHints = false,
    --   includeInlayEnumMemberValueHints = true,
    -- },
    updateImportsOnFileMove = { enabled = "always" },
    suggest = {
      completeFunctionCalls = true,
    },
    preferences = {
      importModuleSpecifierPreference = "shortest",
      preferTypeOnlyAutoImports = true,
    },
    tsserver = {
      maxTsServerMemory = 8192,
    },
  }

  -- local capabilities = vim.lsp.protocol.make_client_capabilities()
  -- capabilities.textDocument.completion.completionItem.snippetSupport = true

  local svelte_lsp_capabilities = vim.lsp.protocol.make_client_capabilities()
  svelte_lsp_capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = true
  vim.lsp.config("svelte", {
    capabilities = svelte_lsp_capabilities,
    -- Look at .git, not package.json to make sure that monorepos work properly
    -- root_markers = { ".git" },
    settings = {
      typescript = ts_server_settings,
      javascript = ts_server_settings,
    },
  })

  vim.lsp.config("vtsls", {
    settings = {
      typescript = ts_server_settings,
      javascript = ts_server_settings,
      complete_function_calls = true,
      vtsls = {
        enableMoveToFileCodeAction = true,
        autoUseWorkspaceTsdk = true,
        experimental = {
          completion = {
            enableServerSideFuzzyMatch = true,
          },
        },
        tsserver = {
          maxTsServerMemory = 8192,
          globalPlugins = {
            {
              name = "typescript-svelte-plugin",
              location = vim.fn.expand("$HOME/.pnpm/5/node_modules/typescript-svelte-plugin"),
              enableForWorkspaceTypeScriptVersions = true,
            },
          },
        },
      },
    },
    filetypes = {
      "javascript",
      "typescript",
    },
  })

  vim.lsp.config("ts_ls", {
    init_options = {
      maxTsServerMemory = 32768,
      preferences = ts_server_settings.preferences,
      plugins = {
        {
          name = "typescript-svelte-plugin",
          location = vim.fn.expand("$HOME/.pnpm/5/node_modules/typescript-svelte-plugin"),
          languages = {
            "typescript",
            "javascript",
            "svelte",
          },
          enableForWorkspaceTypeScriptVersions = true,
        },
      },
    },
    settings = {
      typescript = ts_server_settings,
      javascript = ts_server_settings,
      complete_function_calls = true,
    },
  })

  vim.lsp.config("tsgo", {
    settings = {
      typescript = ts_server_settings,
      javascript = ts_server_settings,
      complete_function_calls = true,
    },
  })

  -- vim.lsp.config("harper_ls", {
  --   settings = {
  --     ["harper-ls"] = {
  --       linters = {
  --         SentenceCapitalization = false,
  --         SpellCheck = false,
  --       },
  --     },
  --   },
  -- })

  vim.lsp.config("lua_ls", {
    settings = {
      Lua = {
        runtime = {
          version = "LuaJIT",
        },
        diagnostics = {
          globals = { "vim", "dd" },
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

  -- vim.lsp.config["markdown-frontmatter"] = {
  --   cmd = { "node", "~/Documents/projects/markdown-frontmatter-lsp/server/out/server.js" },
  --   filetypes = { "markdown" },
  --   root_markers = { ".git" },
  -- }
  -- vim.lsp.enable("markdown-frontmatter")

  -- vim.lsp.config("pyright", {
  --   settings = {
  --     pyright = {
  --       inlayHints = {
  --         parameterTypes = false,
  --       },
  --     },
  --   },
  -- })

  vim.lsp.config("rust_analyzer", {
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

  vim.lsp.config("yamlls", {
    filetypes = { "yaml", "yaml.docker-compose", "yaml.gitlab", "yaml.helm-values", "markdown.yaml" },
    settings = {
      yaml = {
        schemaStore = {
          enable = true,
          -- The standard file minus some overlay aggressive matching rules for a few schemas
          url = "https://raw.githubusercontent.com/dimfeld/schemastore/refs/heads/master/src/api/json/catalog.json",
        },
      },
    },
  })

  vim.lsp.config("eslint", {
    settings = {
      eslint = {
        workingDirectories = {
          mode = "auto",
        },
      },
    },
  })

  -- The order of initialization is important here because it determines the order in which code actions show up
  -- when more than one LS has actions.
  vim.lsp.enable({
    "svelte",
    -- "vtsls",
    -- "ts_ls",
    "tsgo",
    "cssls",
    "eslint",
    "gopls",
    "html",
    "jsonls",
    "lua_ls",
    "pyright",
    "rust_analyzer",
    "tailwindcss",
    "terraformls",
    "yamlls",
    -- "harper_ls",
  })
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

  if not vim.b._first_lsp_attached then
    vim.b._first_lsp_attached = true

    vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
      buffer = buffer,
      callback = vim.lsp.codelens.refresh,
    })
  end

  if client.name == "svelte" then
    -- Ensure that Svelte LSP updates on TS file changes
    -- This isn't really the proper way to do this but the proper support doesn't seem to work.
    local augroup = vim.api.nvim_create_augroup("SvelteLspAttached", {})
    vim.api.nvim_create_autocmd("BufWritePost", {
      group = augroup,
      pattern = { "*.js", "*.ts", "*.mjs", "*.mts", "*.cjs", "*.cts" },
      callback = function(ctx)
        client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.match })
      end,
    })
  end

  -- vim.api.nvim_create_autocmd("CursorHold", {
  --   buffer = buffer,
  --   group = augroup,
  --   callback = function()
  --     vim.diagnostic.open_float()
  --   end,
  -- })
end

local function configure_lsp_attach()
  local augroup = vim.api.nvim_create_augroup("MyLspAttach", {})

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
    cond = not vim.g.vscode,
    opts = {},
    config = function(_, opts)
      configure_lsp_attach()
      configure_lsp_servers()

      vim.diagnostic.config({
        virtual_lines = {
          current_line = true,
        },
        -- virtual_text = {
        --   spacing = 4,
        --   current_line = true,
        --   source = "if_many",
        --   prefix = "●",
        --   severity = { vim.diagnostic.severity.ERROR, vim.diagnostic.severity.WARN },
        -- },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "•",
            [vim.diagnostic.severity.WARN] = "•",
            [vim.diagnostic.severity.INFO] = "•",
            [vim.diagnostic.severity.HINT] = "•",
          },
        },
        -- float = {
        --   severity_sort = true,
        --   source = true,
        -- },
        -- No need for this now that we have virtual_lines
        jump = {
          float = false,
        },
        severity_sort = true,
      })
    end,
  },

  {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    opts = {},
    enabled = false,
    config = function(_, opts)
      require("typescript-tools").setup({
        settings = {
          expose_as_code_action = "all",
          tsserver_max_memory = 16384,
          tsserver_plugins = {
            "typescript-svelte-plugin",
            -- {
            --   name = "typescript-svelte-plugin",
            --   location = vim.fn.expand("$HOME/.pnpm/5/node_modules/typescript-svelte-plugin"),
            --   enableForWorkspaceTypeScriptVersions = true,
            -- },
          },
        },
      })
    end,
  },

  {
    "hrsh7th/nvim-cmp",
    cond = not vim.g.vscode,
    dependencies = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-nvim-lsp",
      -- "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "onsails/lspkind-nvim",
      {
        "cmp-async-path",
        -- dir = "~/Documents/projects/cmp-async-path",
        url = "https://github.com/dimfeld/cmp-async-path",
      },
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
        confirmation = {
          get_commit_characters = function(commit_characters)
            -- Disable all commit characters
            return {}
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
          [",c"] = cmp.mapping(function(fallback)
            if cmp.visible() and cmp.get_active_entry() then
              cmp.confirm()
            else
              fallback()
            end
          end, { "i" }),
          ["<C-e>"] = cmp.mapping.abort(),
          -- Close and perform the arrow movement
          ["<Up>"] = function(fallback)
            cmp.close()
            fallback()
          end,
          ["<Down>"] = function(fallback)
            cmp.close()
            fallback()
          end,
          ["<Left>"] = function(fallback)
            cmp.close()
            fallback()
          end,
          ["<Right>"] = function(fallback)
            cmp.close()
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
          -- { name = "codeium" },
          { name = "nvim_lsp" },
        }, {
          { name = "async_path", option = { label_trailing_slash = true } },
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

      -- Use cmdline & path source for ':'
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline({
          -- ["<Tab>"] = { c = handle_tab_complete(cmp.select_next_item) },
          -- ["<S-Tab>"] = { c = handle_tab_complete(cmp.select_prev_item) },
        }),
        window = {
          documentation = {
            border = "rounded",
            zindex = 65535,
          },
        },
        sources = cmp.config.sources({
          { name = "async_path", option = { label_trailing_slash = true } },
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
