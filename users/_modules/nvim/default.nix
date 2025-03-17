{ rootPath, pkgs, ... }:

let
  vars = import "${rootPath}/.secrets/git_vars.nix";
  octoTemplate = builtins.readFile ./astronvim_templated/lua/plugins/octo-nvim.lua;
  octoConfig = builtins.replaceStrings ["<githubAlias>"] [vars.bshGit.host] octoTemplate;
in {
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

      # LSPs and Languages
      #
      ## Rust
      rust-analyzer  # required by astrocommunity.pack.rust

      ## Python
      python3  # required by astrocommunity.pack.python-ruff

      ## Nix
      nixd  # required by astrocommunity.pack.nix
      deadnix  # required by astrocommunity.pack.nix
      statix  # required by astrocommunity.pack.nix

      ## Node
      nodejs_23

      # GitHub
      gh  # required by astrocommunity.git.octo-nvim
    ];

    # TODO: The harper dictionary is located at `~/.config/harper-ls/dictionary.txt`, it would be nice if we could manage that via this repo
    # TODO: The spell dictionary is located at `~/.config/nvim/spell/en.utf-8.add`, it would be nice if we could manage that via this repo (https://github.com/psliwka/vim-dirtytalk)

    file = {
      "./.config/nvim/" = {
        source = ./astronvim;
        recursive = true;
      };
    };
    file.".config/nvim/lua/plugins/octo-nvim.lua".text = octoConfig;
  };
}
