{ inputs, lib, config, pkgs, ... }:

{
  programs.nixvim = {
    enable = true;
    viAlias = true;
    vimAlias = true;

    colorschemes.catppuccin.enable = true;
  };

  home.sessionVariables = {
    EDITOR = "vim";
    VISUAL = "vim";
  };
}
