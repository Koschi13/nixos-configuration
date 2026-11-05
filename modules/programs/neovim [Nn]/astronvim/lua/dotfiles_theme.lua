-- The theme generated from `dotfiles.theme` by neovim.nix. `apply` is called
-- by `theme` to switch running instances.
--
-- `theme.lua` is loaded with `dofile` instead of `require`: `vim.loader` treats
-- a file as unchanged while its size and mtime are, and the files of all
-- variants have mtime 1 in the Nix store and often the same size.
local M = {}

function M.load()
  return dofile(vim.fn.stdpath("config") .. "/theme.lua")
end

function M.apply()
  local theme = M.load()
  vim.o.background = theme.background
  vim.cmd.colorscheme(theme.colorscheme)
end

return M
