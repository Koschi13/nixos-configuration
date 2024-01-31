{ pkgs, zsh-calc, ... }:

{
  imports = [ ./plugins/default.nix ./starship.nix ];

  # BASH
  programs.bash.enable = true;

  # ZSH
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    defaultKeymap = "viins";
    syntaxHighlighting = {
      # replace by fast-syntac-hightlighting
      enable = false;
    };
    autocd = true;
    dotDir = ".config/zsh";

    envExtra = (builtins.readFile ./envExtra);
    initExtra = (builtins.readFile ./initExtra);
    initExtraBeforeCompInit = (builtins.readFile ./initExtraBeforeCompInit);

    history = {
      share = true;
      expireDuplicatesFirst = true;
      save = 100000;
      size = 100000;
      ignoreDups = true;
      ignoreAllDups = true;
      ignoreSpace = true;

      # Save timestamp of command
      extended = true;

      # patterns listed here will not be added to the history
      ignorePatterns = [ "rm *" "pkill *" ];
    };

    shellAliases = {
      # bat
      cat = "bat --plain";

      # eza
      ls = "eza";
      l = "eza -lgFh";
      la = "eza -lgaFh";
      lr = "eza -lRFr";
      lrr = "eza -lRFL";
      lt = "eza -lgRFhs date";
      ll = "eza -lh";

      # ip
      ip = "ip --color=auto";

      # kubectl
      k = "kubectl";
    };
  };

  # Commandline tools
  programs = {
    htop.enable = true;
    bat = {
      enable = true;
      config = { pager = "less -FR"; };
    };
    jq.enable = true;

    eza = {
      enable = true;
      icons = true;
      extraOptions = [ "--group-directories-first" ];
    };

    fzf = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };

    z-lua = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableAliases = true;
    };
  };
}
