return {
  {
    "habamax/vim-asciidoctor",
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
  "chr4/nginx.vim",

  {
    "leafOfTree/vim-svelte-plugin",
    init = function()
      vim.g.svelte_preprocessor_tags = {
        { name = "postcss", tag = "style", as = "scss" },
      }

      vim.g.svelte_preprocessors = { "typescript", "postcss", "scss" }

      vim.g.vim_svelte_plugin_use_typescript = 1
      vim.g.vim_svelte_plugin_use_sass = 1
    end,
  },
  "cakebaker/scss-syntax.vim",
  "rust-lang/rust.vim",
  "cespare/vim-toml",
  "mechatroner/rainbow_csv",
  -- "fatih/vim-go",

  -- Typescript syntax highlighting
  "HerringtonDarkholme/yats.vim",

  "gutenye/json5.vim",
  "HiPhish/jinja.vim",
  -- Aviator Git CLI highlighting
  "aviator-co/av-vim-plugin",
  "othree/javascript-libraries-syntax.vim",

  -- justfile highlighting
  "NoahTheDuke/vim-just",
}
