-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  { import = "astrocommunity.bars-and-lines.dropbar-nvim" },
  { import = "astrocommunity.bars-and-lines.smartcolumn-nvim" },
  { import = "astrocommunity.bars-and-lines.vim-illuminate" },
  { import = "astrocommunity.colorscheme.catppuccin" },
  { import = "astrocommunity.docker.lazydocker" },
  { import = "astrocommunity.git.neogit" },
  { import = "astrocommunity.git.octo-nvim" },
  { import = "astrocommunity.markdown-and-latex.render-markdown-nvim" },
  { import = "astrocommunity.media.codesnap-nvim" },
  { import = "astrocommunity.pack.bash" },
  { import = "astrocommunity.pack.docker" },
  { import = "astrocommunity.pack.harper" },
  { import = "astrocommunity.pack.helm" },
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.pack.markdown" }, -- There is a problem with the `icu` package, which can be worked around with DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1
  { import = "astrocommunity.pack.nix" }, -- https://astronvim.github.io/astrocommunity/#nix
  { import = "astrocommunity.pack.python-ruff" },
  { import = "astrocommunity.pack.rainbow-delimiter-indent-blankline" },
  { import = "astrocommunity.pack.rust" },
  { import = "astrocommunity.pack.terraform" },
  { import = "astrocommunity.recipes.astrolsp-no-insert-inlay-hints" },
}
