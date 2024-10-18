function pum_visible()
  return vim.fn["coc#pum#visible"]() == 1
end

-- Cancel confirmation when arrow key is pressed
function close_pum_when_pressed(key)
  vim.keymap.set("i", key, function()
    if pum_visible() then
      vim.fn["coc#pum#stop"]()
    end

    return key
  end, { expr = true })
end

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

function setup_float_reposition()
  -- This doesn't work yet.
  local augroup = vim.api.nvim_create_augroup("RepositionFloat", {})
  vim.api.nvim_create_autocmd("User", {
    -- This doesn't work right yet.
    -- The scrollbar doesn't relocate with the window
    -- When we jump to the next diagnostic, the popup relocates after this code is called.
    group = augroup,
    pattern = "CocOpenFloat",
    callback = function(ev)
      local float_win = vim.g.coc_last_float_win
      if not window_helpers.is_coc_diagnostic_window(float_win) then
        -- Don't reposition for normal popups, just for things like diagnostic window
        return
      end

      local current_win = vim.api.nvim_get_current_win()
      local buf = vim.api.nvim_win_get_buf(float_win)
      local win_height = vim.api.nvim_win_get_height(current_win)
      local win_width = vim.api.nvim_win_get_width(current_win)
      local float_config = vim.api.nvim_win_get_config(float_win)
      local new_col = math.floor((win_width - float_config.width))
      local new_row = win_height - float_config.height - 1

      -- Not working yet, it overrides a lot of the existing window config that I
      -- don't know how to get yet.
      -- vim.fn["coc#float#create_float_win"](float_win, buf, {
      --   relative = "editor",
      --   row = new_row,
      --   width = float_config.width,
      --   height = float_config.height,
      --   col = new_col,
      -- })

      -- This also doesn't work yet, because it doesn't move the scrollbar and related windows along with the main
      -- window. Ideally we could get the original config object and reuse it, just changing the values we want, but I don't think there's
      -- an easy way to do that.
      -- vim.api.nvim_win_set_config(float_win, {
      --   relative = "win",
      --   win = current_win,
      --   row = win_height,
      --   col = 0,
      --   anchor = "SW",
      -- })
    end,
  })
end

function setup_coc()
  -- Tab and S-Tab navigate completion popup, if it's open
  vim.keymap.set("i", "<TAB>", function()
    if pum_visible() then
      return vim.fn["coc#pum#next"](1)
    else
      return "<TAB>"
    end
  end, { expr = true, silent = true })

  vim.keymap.set("i", "<S-TAB>", function()
    if pum_visible() then
      return vim.fn["coc#pum#prev"](1)
    else
      return "<S-TAB>"
    end
  end, { expr = true, silent = true })

  close_pum_when_pressed("<up>")
  close_pum_when_pressed("<down>")
  close_pum_when_pressed("<left>")
  close_pum_when_pressed("<right>")

  -- Open completion popup
  vim.keymap.set("i", "<c-space>", function()
    vim.fn["coc#start"]()
  end, { silent = true })

  -- TODO need to port this one?
  -- Close preview window when completion is done.
  local auGroup = vim.api.nvim_create_augroup("completion", {})
  vim.api.nvim_create_autocmd("CompleteDone", {
    group = auGroup,
    pattern = "*",
    callback = function()
      if not pum_visible() and vim.fn["getcmdwintype"]() == "" then
        vim.cmd("pclose")
      end
    end,
  })

  -- Allow triggering code action, such as adding import, from completion window
  vim.keymap.set("i", "<leader>c", function()
    if pum_visible() then
      return vim.fn["coc#pum#confirm"]()
    else
      return "<leader>c"
    end
  end, { silent = true, expr = true, desc = "Trigger code action" })

  vim.keymap.set("n", "<leader>dd", "<Plug>(coc-definition)", { silent = true })
  vim.keymap.set("n", "<leader>dj", "<Plug>(coc-implementation)", { silent = true })
  vim.keymap.set("n", "<leader>dg", function()
    vim.cmd("call CocActionAsync('diagnosticInfo', 'float')")
  end, { silent = true })
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
    "coc-lua",
    "coc-pyright",
    "coc-rust-analyzer",
    "coc-svelte",
    "coc-tsserver",
    "coc-xml",
    "@yaegassy/coc-tailwindcss3",
  }

  -- Documentation with K and c-K
  vim.keymap.set("n", "K", toggle_documentation, {})
  vim.keymap.set("i", "<C-K>", toggle_signature_help, {})

  vim.api.nvim_create_user_command("Format", function()
    vim.fn.CocAction("runCommand", "editor.action.formatDocument")
  end, {})
end

return {
  { "neoclide/coc.nvim", enabled = false, branch = "release", config = setup_coc },
}
