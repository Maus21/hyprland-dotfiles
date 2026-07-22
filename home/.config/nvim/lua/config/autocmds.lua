-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

local uv = vim.uv or vim.loop
local state_dir = vim.fn.expand("~/.cache/hypr-theme-switcher")
local reload_pending = false

local function reload_synced_theme()
  if reload_pending then
    return
  end

  reload_pending = true
  vim.defer_fn(function()
    reload_pending = false
    if vim.g.colors_name == "hypr-sync" then
      pcall(vim.cmd.colorscheme, "hypr-sync")
    end
  end, 60)
end

vim.api.nvim_create_autocmd("VimEnter", {
  group = vim.api.nvim_create_augroup("hypr_theme_sync", { clear = true }),
  once = true,
  callback = function()
    local watcher = uv.new_fs_event()
    if not watcher then
      return
    end

    local ok = watcher:start(state_dir, {}, function(err, filename)
      if not err and (not filename or filename == "nvim-theme.lua") then
        vim.schedule(reload_synced_theme)
      end
    end)

    if ok then
      vim._hypr_theme_watcher = watcher
    else
      watcher:close()
    end
  end,
})

vim.api.nvim_create_autocmd("VimLeavePre", {
  group = "hypr_theme_sync",
  callback = function()
    local watcher = vim._hypr_theme_watcher
    if watcher and not watcher:is_closing() then
      watcher:stop()
      watcher:close()
    end
    vim._hypr_theme_watcher = nil
  end,
})
