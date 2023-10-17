{ config, pkgs, ...}:

let
  pkgsUnstable = import <nixpkgs-unstable> {};
in

{
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
    defaultKeymap = "viins";

    envExtra = ''
      gpg-connect-agent /bye
      export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
    '';

    initExtra = ''
    '';

    history = {
      share = true;

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
    };

  };

  # prompt
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
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
  };
}
