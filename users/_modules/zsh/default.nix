{
  pkgs,
  zsh-calc,
  ...
}: {
  imports = [
    ./plugins/default.nix
    ./starship.nix
  ];

  # BASH
  programs.bash.enable = true;

  # ZSH
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    defaultKeymap = "viins";
    syntaxHighlighting = {
      # replace by fast-syntac-hightlighting
      enable = false;
    };
    autocd = true;
    dotDir = ".config/zsh";

    envExtra = builtins.readFile ./envExtra;
    initExtra = builtins.readFile ./initExtra;
    initExtraBeforeCompInit = builtins.readFile ./initExtraBeforeCompInit;

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
      ignorePatterns = [
        "rm *"
        "pkill *"
      ];
    };

    shellAliases = {
      # bat
      cat = "bat --plain";

      # eza
      ls = "eza";
      l = "eza -lgh";
      la = "eza -lgah";
      lr = "eza -lRr";
      lrr = "eza -lRF";
      lt = "eza -lgRhs date";
      ll = "eza -lh";

      # ip
      ip = "ip --color=auto";

      # kubectl
      k = "kubectl";

      # nvim
      vim = "nvim";

      # delta (diff tool)
      diffd = "delta";
    };
  };

  # Commandline tools
  programs = {
    htop.enable = true;
    bat = {
      enable = true;
      config = {
        pager = "less -FR";
      };
    };
    jq.enable = true;

    eza = {
      enable = true;
      icons = "auto";
      extraOptions = ["--group-directories-first"];
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
