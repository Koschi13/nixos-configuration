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

      # Tools
      #
      # See requirements here: https://docs.astronvim.com/
      bottom
      gdu

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
