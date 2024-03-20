local auGroup = vim.api.nvim_create_augroup("tera_ftdetect", {})

filetypes = {
  js = "javascript",
  ts = "typescript",
  rs = "rust",
}

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  group = auGroup,
  pattern = "*.tera",
  callback = function()
    local filename = vim.fn.expand("<afile>")
    -- Remove the .tera extension
    filename = filename:gsub(".tera$", "")
    -- Get the extension now
    local ext = vim.fn.fnamemodify(filename, ":e")

    if ext == "" then
      vim.bo.filetype = "jinja"
    else
      local filetype = filetypes[ext] or ext
      vim.bo.filetype = filetype .. ".jinja"
    end
  end,
})
