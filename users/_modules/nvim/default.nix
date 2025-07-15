{pkgs, ...}: let
  userDictionary = builtins.readFile ./user-dictionary.txt;
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
      unzip # needed for Mason
      lazydocker
      imagemagick # needed for snacks.nvim
      ghostscript # needed for snacks.nvim
      lua54Packages.luarocks  # needed for lazy.nvim

      # LSPs and Languages
      #
      ## Rust
      rust-analyzer # required by astrocommunity.pack.rust

      ## Python
      python3 # required by astrocommunity.pack.python-ruff

      ## Nix
      nixd # required by astrocommunity.pack.nix
      deadnix # required by astrocommunity.pack.nix
      statix # required by astrocommunity.pack.nix
      alejandra # required by astrocommunity.pack.nix

      ## Node
      nodejs_24
      icu # needed by nodejs

      # GitHub
      gh # required by astrocommunity.git.octo-nvim
    ];

    # TODO: The spell dictionary is located at `~/.config/nvim/spell/en.utf-8.add`, it would be nice if we could manage that via this repo (https://github.com/psliwka/vim-dirtytalk)

    file = {
      ".config/nvim/" = {
        source = ./astronvim;
        recursive = true;
      };
      ".config/harper-ls/user-dictionary.txt".text = userDictionary;
    };
  };
}
