{ astronvim, pkgs, ... }:

# AstroVim is installed manually since it is not supported by flakes
# TODO: clone git via nix to ~/.config/nvim
{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
  };

  home = {
    sessionVariables = { VISUAL = "vim"; };
    packages = with pkgs; [ gcc ];
  };

  #
  # AstroNvim
  #
  # Custom user settings for AstroNvim: https://github.com/AstroNvim/user_example
  home.file = {
    ".config/astronvim/lua/user/init.lua".text =
      (builtins.readFile ./astronvim/lua/user/init.lua);
    ".config/astronvim/lua/user/plugins/init.lua".text =
      (builtins.readFile ./astronvim/lua/user/plugins/init.lua);
  };
}
