return {
  {
    "habamax/vim-asciidoctor",
    ft = "asciidoc",
    init = function()
      vim.g["asciidoctor_folding"] = 1
      vim.g["asciidoctor_fenced_languages"] = {
        "sql",
        "svelte",
        "rust",
        "bash",
      }
    end,
  },

  -- Syntax highlighting for nginx
  { "chr4/nginx.vim", ft = { "nginx" } },

  { "cakebaker/scss-syntax.vim", ft = { "scss", "postcss", "pcss" } },
  { "rust-lang/rust.vim", ft = "rust" },
  { "cespare/vim-toml", ft = "toml" },
  { "mechatroner/rainbow_csv", ft = "csv" },
  -- "fatih/vim-go",

  { "gutenye/json5.vim", ft = "json5" },

  "HiPhish/jinja.vim",
  -- Aviator Git CLI highlighting
  "aviator-co/av-vim-plugin",

  -- Javascript

  { "othree/javascript-libraries-syntax.vim", ft = { "javascript", "typescript", "svelte" } },
  -- Generate JSDoc commands based on function signature
  { "heavenshell/vim-jsdoc", ft = { "javascript", "typescript", "svelte" } },
  -- Typescript syntax highlighting
  { "HerringtonDarkholme/yats.vim", ft = { "typescript", "svelte" } },

  {
    "leafOfTree/vim-svelte-plugin",
    ft = "svelte",
    init = function()
      vim.g.svelte_preprocessor_tags = {
        { name = "postcss", tag = "style", as = "scss" },
      }

      vim.g.svelte_preprocessors = { "typescript", "postcss", "scss" }

      vim.g.vim_svelte_plugin_use_typescript = 1
      vim.g.vim_svelte_plugin_use_sass = 1
    end,
  },

  -- justfile highlighting
  { "NoahTheDuke/vim-just", ft = "just" },

  -- Hashicorp Tools
  { "hashivim/vim-hashicorp-tools", ft = { "hcl", "terraform" } },
  {
    "jvirtanen/vim-hcl",
    ft = { "hcl", "terraform" },
  },

  -- Markdown
  { "godlygeek/tabular", ft = { "markdown" } },
  { "plasticboy/vim-markdown", ft = { "markdown" } },
  {
    "iamcco/markdown-preview.nvim",
    ft = { "markdown" },
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
  },
}
