{ config, pkgs, ...}:

{
  imports = [
    ./starship.nix
  ];

  # BASH
  programs.bash.enable = true;

  # ZSH
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    syntaxHighlighting = {
      enable = true;
    };
    autocd = true;
    dotDir = ".config/zsh";

    envExtra = ''
      gpg-connect-agent /bye
      export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
    '';

    initExtra = ''
      bindkey -v                       # Use Vim-keys inside of the Terminal

      # Autosuggest
      bindkey '^ ' autosuggest-accept  # Use ctrl+space to apply the suggestion
      ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=(
        forward-char
        end-of-line
        vi-forward-char
        vi-end-of-line
        vi-add-eol
      )

      # Changing directories
      setopt pushd_ignore_dups         # Dont push copies of the same dir on stack.
      setopt pushd_minus               # Reference stack entries with "-".
    '';

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

    plugins = [
      {
        name = "fast-syntax-highlighting";
        file = "fast-syntax-highlighting.plugin.zsh";
        src = "${pkgs.zsh-fast-syntax-highlighting}/share/zsh/site-functions";
      }
      #{
      #  name = "zsh-colored-man-pages";
      #  file = "colored-man-pages.plugin.zsh";
      #  src = "${zsh-colored-man-pages}/share/zsh-colored-man-pages";
      #}
      {
        name = "zsh-fzf-tab";
        file = "fzf-tab.plugin.zsh";
        src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
      }
      {
        name = "forgit";
        file = "forgit.plugin.zsh";
        src = "${pkgs.zsh-forgit}/share/forgit";
      }
      {
        name = "zvm";
	file = "zsh-vi-mode.plugin.zsh";
	src = "${pkgs.zsh-vi-mode}/share/zsh-vi-mode";
      }
    ];
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
      icons = true;
      extraOptions = [
        "--group-directories-first"
      ];
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
