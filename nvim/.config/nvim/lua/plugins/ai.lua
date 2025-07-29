local cmdbar = require("config.telescope_commandbar")

-- local completion_assistant = "copilot"
local completion_assistant = vim.env.COMPLETION_ASSISTANT or "codeium.nvim"
if vim.g.vscode then
  completion_assistant = ""
end
-- local completion_assistant = "sourcegraph"
-- local completion_assistant = "supermaven"

return {
  { "sourcegraph/sg.nvim", cond = completion_assistant == "sourcegraph" },

  {
    "github/copilot.vim",
    cond = completion_assistant == "copilot",
    enabled = false,
    init = function()
      vim.g.copilot_no_tab_map = true
      vim.g.copilot_filetypes = {
        markdown = true,
      }
    end,
    config = function()
      local acceptCmd = 'copilot#Accept("")'
      local acceptKeyOpts = { silent = true, expr = true, script = true, replace_keycodes = false }
      vim.keymap.set("i", "<C-J>", acceptCmd, acceptKeyOpts)
      vim.keymap.set("i", "<C-]>", acceptCmd, acceptKeyOpts)
    end,
  },
  {
    -- "Exafunction/codeium.vim",
    -- branch = "main",
    "dimfeld/codeium.vim",
    branch = "all-fixes",
    dir = "~/Documents/projects/codeium.vim",
    name = "codeium.vim",
    enabled = false,
    cond = completion_assistant == "codeium.vim",
    init = function()
      vim.g.codeium_enabled = true
      vim.g.codeium_no_map_tab = true
      vim.g.codeium_idle_delay = 200
    end,
    opts = {
      enable_chat = true,
    },
    config = function(_, opts)
      local acceptKeyOpts = { silent = true, expr = true, script = true, replace_keycodes = false }
      vim.keymap.set("i", "<C-J>", "codeium#AcceptNextLine()", acceptKeyOpts)
      vim.keymap.set("i", "<C-]>", "codeium#Accept()", acceptKeyOpts)
      vim.keymap.set("i", "<C-p>", vim.fn["codeium#Complete"])
    end,
  },
  {
    "dimfeld/codeium.nvim",
    name = "codeium.nvim",
    branch = "all-fixes",
    cond = completion_assistant == "codeium.nvim",
    -- dir = "~/Documents/projects/codeium.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "hrsh7th/nvim-cmp",
      "nvim-lualine/lualine.nvim",
    },
    opts = {
      enable_cmp_source = false,
      quiet = true,
      virtual_text = {
        enabled = true,
        filetypes = {
          AvanteInput = false,
        },
        key_bindings = {
          accept = "<C-]>",
          -- accept_line = "<C-j>",
          -- clear = "",
        },
      },
    },
    config = function(_, opts)
      require("codeium").setup(opts)
      require("codeium.virtual_text").set_statusbar_refresh(require("lualine").refresh)

      cmdbar.add_commands({
        {
          name = "Codeium Chat",
          category = "AI",
          action = function()
            vim.cmd("Codeium Chat")
          end,
        },
      })
    end,
  },
  {
    "supermaven-inc/supermaven-nvim",
    cond = completion_assistant == "supermaven",
    event = "VeryLazy",
    opts = {
      keymaps = {
        accept_suggestion = "<C-]>",
        clear_suggestion = "<C-J>",
        accept_word = "<M-]>",
      },
      color = {
        suggestion_color = "#eeaaaa",
        cterm = 10,
      },
    },
  },

  {
    "dustinblackman/oatmeal.nvim",
    enabled = false,
    event = "VeryLazy",
    cond = not vim.g.vscode,
    opts = {
      backend = "ollama",
      model = "deepseek-coder-v2:16b-lite-instruct-fp16",
    },
  },
  {
    "joshuavial/aider.nvim",
    enabled = true,
    event = "VeryLazy",
    cond = not vim.g.vscode,
    opts = {
      auto_manage_context = true,
      default_keybindings = false,
    },
    config = function(_, opts)
      require("aider").setup(opts)
      cmdbar.add_commands({
        {
          name = "Aider",
          category = "AI",
          action = function()
            AiderOpen()
          end,
        },
        {
          name = "Aider Background",
          category = "AI",
          action = function()
            AiderBackground()
          end,
        },
      })
    end,
  },
  {
    "zbirenbaum/copilot.lua",
    event = "VeryLazy",
    cond = not vim.g.vscode,
    opts = {
      -- Just using this for avante config, don't need the UI functionality
      suggestion = {
        enabled = false,
      },
      panel = {
        enabled = false,
      },
    },
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "main",
    cond = not vim.g.vscode,
    dependencies = {
      { "zbirenbaum/copilot.lua" }, -- or github/copilot.vim
      { "nvim-lua/plenary.nvim" }, -- for curl, log wrapper
    },
    build = "make tiktoken", -- Only on MacOS or Linux
    opts = {
      debug = false, -- Enable debugging
      model = "claude-3.5-sonnet",
      mappings = {
        reset = {
          normal = "gr",
          insert = "",
        },
      },
      prompts = {
        PullRequest = {
          prompt = "Please provide a pull request description for this git diff.",
          selection = function(source)
            local default_branch = require("lib.git").find_default_branch()

            local select = require("CopilotChat.select")
            local select_buffer = select.buffer(source)
            if not select_buffer then
              return nil
            end

            local dir = vim.fn.getcwd():gsub(".git$", "")

            local cmd = "git -C " .. dir .. " diff --no-color --no-ext-diff " .. default_branch
            local handle = io.popen(cmd)
            if not handle then
              return nil
            end

            local result = handle:read("*a")
            handle:close()
            if not result or result == "" then
              return nil
            end

            select_buffer.filetype = "diff"
            select_buffer.lines = result
            return select_buffer
          end,
        },
        Explain = "Please explain how the following code works.",
        Tests = "Please explain how the selected code works, then generate unit tests for it.",
        Review = "Please review the following code and provide suggestions for improvement.",
        Refactor = "Please refactor the following code to improve its clarity and readability.",
        FixCode = "Please fix the following code to make it work as intended.",
        FixError = "Please explain the error in the following text and provide a solution.",
        BetterNamings = "Please provide better names for the following variables and functions.",
        Documentation = "Please provide documentation for the following code.",
        Summarize = "Please summarize the following text.",
        Spelling = "Please correct any grammar and spelling errors in the following text.",
        Wording = "Please improve the grammar and wording of the following text.",
        Concise = "Please rewrite the following text to make it more concise.",
      },
    },
    -- See Commands section for default commands if you want to lazy load on them
    config = function(_, opts)
      local existing_prompts = require("CopilotChat.config").prompts

      -- Add existing_prompts to opts.prompts, if the key doesn't already exist
      for k, v in pairs(existing_prompts) do
        if not opts.prompts[k] then
          opts.prompts[k] = v
        elseif type(opts.prompts[k]) == "string" and type(v) == "table" then
          -- If our prompt is a string and the default prompt is a table, merge the two
          local prompt = opts.prompts[k]
          opts.prompts[k] = v
          opts.prompts[k].prompt = prompt
        end
      end

      require("CopilotChat").setup(opts)

      --- @param name string
      --- @param prompt string | table
      --- @return CommandBarAction
      local function ask_action(name, prompt)
        --- @type CommandBarAction
        return {
          name = name,
          category = "AI",
          action = function(o)
            cmdbar.restore_selection(o.cursor)
            require("CopilotChat").ask(
              type(prompt) == "string" and prompt or prompt.prompt,
              type(prompt) == "string" and nil or prompt
            )
          end,
        }
      end

      --- @type CommandBarAction[]
      local commands = {
        {
          name = "Copilot Chat",
          category = "AI",
          action = function(o)
            cmdbar.restore_selection(o.cursor)
            require("CopilotChat").toggle()
          end,
        },
        {
          name = "Select Copilot Chat Model",
          category = "AI",
          action = function()
            local M = require("CopilotChat")
            vim.notify("Current model: " .. M.config.model, vim.log.levels.INFO)
            M.select_model()
          end,
        },
        {
          name = "Copilot Help Actions",
          category = "AI",
          action = function(o)
            cmdbar.restore_selection(o.cursor)
            local actions = require("CopilotChat.actions")
            require("CopilotChat.integrations.telescope").pick(actions.help_actions())
          end,
        },
        {
          name = "Copilot Code Actions",
          category = "AI",
          action = function(o)
            cmdbar.restore_selection(o.cursor)
            local actions = require("CopilotChat.actions")
            require("CopilotChat.integrations.telescope").pick(actions.prompt_actions())
          end,
        },
      }

      for name, prompt in pairs(opts.prompts) do
        commands[#commands + 1] = ask_action("Copilot " .. name, prompt)
      end

      cmdbar.add_commands(commands)
    end,
  },
  {
    "yetone/avante.nvim",
    enabled = true,
    cond = not vim.g.vscode,
    event = "VeryLazy",
    version = false,
    build = "make",
    opts = {
      -- provider = "copilot",
      provider = "gemini",
      providers = {
        claude = {
          model = "claude-sonnet-4-sonnet-latest",
          -- max_tokens = 4096,
        },
        gemini = {
          model = "gemini-2.5-flash",
        },
        gemini_pro = {
          __inherits_from = "gemini",
          model = "gemini-2.5-pro",
        },
        ---@type AvanteProvider
        deepseek = {
          endpoint = "https://api.deepseek.com/",
          model = "deepseek-chat",
          api_key_name = "DEEPSEEK_API_KEY",
          parse_curl_args = function(opts, code_opts)
            return {
              url = opts.endpoint,
              headers = {
                ["Accept"] = "application/json",
                ["Content-Type"] = "application/json",
                ["Authorization"] = "Bearer " .. os.getenv(opts.api_key_name),
              },
              body = {
                model = opts.model,
                messages = require("avante.providers").openai.parse_message(code_opts), -- you can make your own message, but this is very advanced
                temperature = 0,
                max_tokens = 4096,
                stream = true, -- this will be set by default.
              },
            }
          end,
          parse_response_data = function(data_stream, event_state, opts)
            require("avante.providers").openai.parse_response(data_stream, event_state, opts)
          end,
        },
      },
    },
    config = function(_, opts)
      require("avante").setup(opts)
      require("avante_lib").load()
    end,
    dependencies = {
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "zbirenbaum/copilot.lua", -- for providers='copilot'
      --- The below is optional, make sure to setup it properly if you have lazy=true
      "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
      {
        -- support for image pasting
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = false,
            },
          },

          filetypes = {
            AvanteInput = {
              drag_and_drop = {
                insert_mode = true,
              },
            },
          },
        },
      },
      "MeanderingProgrammer/render-markdown.nvim",
    },
  },
  {
    "olimorris/codecompanion.nvim",
    cond = not vim.g.vscode,
    event = "VeryLazy",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "hrsh7th/nvim-cmp", -- Optional: For using slash commands and variables in the chat buffer
      "nvim-telescope/telescope.nvim", -- Optional: For using slash commands
      { "stevearc/dressing.nvim", opts = {} }, -- Optional: Improves `vim.ui.select`
    },
    opts = {
      strategies = {
        chat = {
          adapter = "copilot",
        },
        agent = {
          adapter = "copilot",
        },
      },
    },
    config = function(_, opts)
      opts.adapters = {
        copilot = function()
          return require("codecompanion.adapters").extend("copilot", {
            schema = {
              model = {
                default = "claude-3-5-sonnet",
              },
            },
          })
        end,
      }
      require("codecompanion").setup(opts)

      vim.api.nvim_create_user_command("CC", "CodeCompanionChat", {})
      cmdbar.add_commands({
        {
          name = "Code Companion",
          category = "AI",
          action = function()
            vim.cmd("CodeCompanionChat")
          end,
        },
      })
    end,
  },
}
