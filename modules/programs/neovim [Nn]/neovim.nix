{self, ...}: {
  # TODO: unify font settings in lua files via font.nix
  flake.modules = {
    nixos.neovim = {
      programs.neovim = {
        enable = true;
        vimAlias = true;
        viAlias = true;
      };
    };

    homeManager.neovim = {
      config,
      pkgs,
      ...
    }: let
      userDictionary = builtins.readFile ./user-dictionary.txt;
      theme = config.dotfiles.theme.active;
      # Themes without a neovim colorscheme fall back to the builtin one
      colorscheme =
        if theme.integrations.nvim != null
        then theme.integrations.nvim
        else "default";
    in {
      imports = [self.modules.homeManager.dotfiles-theme];

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
          lua54Packages.luarocks # needed for lazy.nvim
          lua51Packages.lua # needed for nvim-dap-python

          # LSPs and Languages
          #
          ## General
          inotify-tools # better file watcher

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
          ".config/nvim/syntax/" = {
            source = ./syntax;
            recursive = true;
          };
          ".config/nvim/ftdetect/" = {
            source = ./ftdetect;
            recursive = true;
          };
          ".config/harper-ls/user-dictionary.txt".text = userDictionary;
          # Loaded by `lua/dotfiles_theme.lua`
          ".config/nvim/theme.lua".text = ''
            return {
              colorscheme = "${colorscheme}",
              background = "${theme.polarity}",
            }
          '';
        };
      };
    };
  };
}
