vim.keymap.set("n", "<leader>dd", "<Plug>(coc-definition)", { silent = true })
vim.keymap.set("n", "<leader>dj", "<Plug>(coc-implementation)", { silent = true })
vim.keymap.set("n", "<leader>dg", "<Plug>(coc-diagnostic-info)", { silent = true })
vim.keymap.set("n", "<leader>rn", "<Plug>(coc-rename)", { silent = true })
vim.keymap.set("n", "[G", "<Plug>(coc-diagnostic-prev)", { silent = true })
vim.keymap.set("n", "]G", "<Plug>(coc-diagnostic-next)", { silent = true })
vim.keymap.set("n", "[g", "<Plug>(coc-diagnostic-prev-error)", { silent = true })
vim.keymap.set("n", "]g", "<Plug>(coc-diagnostic-next-error)", { silent = true })

vim.keymap.set("n", "<leader>al", "<Plug>(coc-codeaction-line)", { silent = true })
vim.keymap.set("n", "<leader>ac", "<Plug>(coc-codeaction-cursor)", { silent = true })
vim.keymap.set("n", "<leader>af", "<Plug>(coc-codeaction)", { silent = true })

vim.g["coc_global_extensions"] = {
  "coc-css",
  "coc-eslint",
  "coc-git",
  "coc-go",
  "coc-html",
  "coc-json",
  "coc-pyright",
  "coc-rust-analyzer",
  "coc-svelte",
  "coc-tsserver",
  "coc-xml",
  "@yaegassy/coc-tailwindcss3",
}

-- Documentation with K and c-K

function toggle_documentation()
  if vim.call("coc#float#has_float") > 0 then
    vim.call("coc#float#close_all")
  else
    show_documentation()
  end
end

function toggle_signature_help()
  if vim.call("coc#float#has_float") > 0 then
    vim.call("coc#float#close_all")
  else
    vim.call("CocActionAsync", "showSignatureHelp", hover_callback)
  end
end

function hover_callback(e, r)
  if r == false then
    vim.call("CocActionAsync", "doHover")
  end
end

function show_documentation()
  local filetype = vim.bo.filetype
  if filetype == "vim" or filetype == "help" then
    vim.cmd("h " .. vim.fn.expand("<cword>"))
  elseif vim.call("coc#rpc#ready") then
    vim.call("CocActionAsync", "doHover")
  else
    vim.cmd("!" .. vim.bo.keywordprg .. " " .. vim.fn.expand("<cword>"))
  end
end

vim.keymap.set("n", "K", toggle_documentation, {})
vim.keymap.set("i", "<C-K>", toggle_signature_help, {})
