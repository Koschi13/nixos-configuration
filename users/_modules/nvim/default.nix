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
      basedpyright
      ruff
      lua-language-server
      rust-analyzer
      harper  # Grammar checker
    ];

    # TODO: The harper dictionary is located at `~/.config/harper-ls/dictionary.txt`, it would be nice if we could manage that via this repo

    file = {
      "./.config/nvim/" = {
        source = ./astronvim;
        recursive = true;
      };
    };
  };
}
