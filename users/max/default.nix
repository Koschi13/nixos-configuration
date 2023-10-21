{ config, pkgs, firefox-addons, ... }:

{
  imports = [
    ./zsh.nix
    ./firefox.nix
    ./nvim.nix
    ./gnome.nix
    ./gpg/default.nix
  ];

  nixpkgs = {
    overlays = [
    ];
    
    config = {
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = (_: true);
    };
  };

  home = {
    # Home Manager needs a bit of information about you and the
    # paths it should manage.
    username = "max";
    homeDirectory = "/home/max";

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "23.05";

    packages = with pkgs; [
      # tools
      ripgrep
      (nerdfonts.override { fonts = [ "DejaVuSansMono" ]; })

      # coding
      alacritty

      # encryption
      git-crypt
      gnupg
      pinentry-gnome
      yubikey-manager
      bitwarden
      bitwarden-cli

      # Messengers
      tdesktop
      signal-desktop
      element-desktop

      # other
      firefox-wayland
      spotify

      # work
      _1password-gui
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
  };

  services = {
    gpg-agent = {
      enable = true;
      pinentryFlavor = "gnome3";
      enableSshSupport = true;
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
