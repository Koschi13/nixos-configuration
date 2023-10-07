{ config, pkgs, ... }:

{
  home = {
    # Home Manager needs a bit of information about you and the
    # paths it should manage.
    username = "max";
    homeDirectory = "/home/max";

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "23.05";

    packages = with pkgs; [
      alacritty
      firefox-wayland
      git-crypt
      gnupg
      pinentry-gnome
      yubikey-manager
      bitwarden
      bitwarden-cli
    ];
    file = {
      ".config/alacritty/alacritty.yaml".text = ''
        env:
          TERM: xterm-256color
      '';
    };
  };

  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;
    gpg.enable = true;
    fzf = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };
    jq.enable = true;
    bat.enable = true;
    htop.enable = true;
    exa = {
      enable = true;
      enableAliases = true;
    };
    firefox = {
      enable = true;
      profiles.default = {
        id = 0;
        name = "Default";
        isDefault = true;
        extensions = with pkgs.nur.repos.rycee.firefox-addons; [
          ublock-origin
          bitwarden
          tridactyl
          multi-account-containers
        ];
      };
    };
  };

  services = {
    gpg-agent = {
      enable = true;
      pinentryFlavor = "gnome3";
      enableSshSupport = true;
    };
  };
}
