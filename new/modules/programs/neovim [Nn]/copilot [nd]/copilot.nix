{
  # Adds GitHub Copilot completions to neovim. Not part of the neovim aspect,
  # as it requires a Copilot subscription, which is only available at work.
  flake.modules.homeManager.neovim-copilot = {
    home.file.".config/nvim/lua/plugins/blink-cmp-copilot.lua".source = ./blink-cmp-copilot.lua;
  };
}
