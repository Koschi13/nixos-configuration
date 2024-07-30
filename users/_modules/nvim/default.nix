{ pkgs, ... }:

{
  home = {
    sessionVariables = {
      VISUAL = "nvim";
      EDITOR = "nvim";
    };

    packages = with pkgs; [
      gcc
      gnumake

      # LSPs
      #
      # All LSPs must be added in ./astronvim/lua/plugins/astrolsp.lua
      pyright
      ruff
    ];

    file = {
      "./.config/nvim/" = {
        source = ./astronvim;
        recursive = true;
      };
    };
  };
}
