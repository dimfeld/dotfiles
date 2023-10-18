_G.MUtils= {}

function _G.reload_nvim_conf()
  for name,_ in pairs(package.loaded) do
    if name:match('^core') or name:match('^lsp') or name:match('^plugins') or name:match('^config') or name:match('^commands') or name:match('^section-wordcount') then
      package.loaded[name] = nil
    end
  end

  vim.cmd('source' .. vim.env.MYVIMRC)
  vim.notify("Nvim configuration reloaded!", vim.log.levels.INFO)
end


