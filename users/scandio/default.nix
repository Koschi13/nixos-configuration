{
  config,
  pkgs,
  firefox-addons,
  rootPath,
  lib,
  ...
}:

{
  imports = [
    ../_modules/zsh/default.nix
    ../_modules/firefox.nix
    ../_modules/nvim/default.nix
    ../_modules/gnome.nix
    ../_modules/gpg/default.nix
    ../_modules/homemanager.nix
    ../_modules/nixpkgs.nix
    ../_modules/rofi/default.nix
    ../_modules/dunst.nix
    ../_modules/waybar/default.nix
    ../_modules/direnv.nix
    ../_modules/sway/default.nix
    ../_modules/swww.nix
    ../_modules/alacritty.nix
    ../_modules/librewolf.nix
    ../_modules/git.nix
  ];

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
      zip
      unzip
      blueman
      timewarrior

      # coding
      jetbrains.pycharm-professional
      jetbrains.rust-rover
      android-studio

      # encryption
      git-crypt
      gnupg
      yubikey-manager
      bitwarden
      bitwarden-cli

      # Messengers
      tdesktop
      signal-desktop
      element-desktop

      # other
      spotify
      pavucontrol
      photoqt
      cifs-utils
      nfs-utils

      # work
      _1password-gui
      slack
      awscli2 # TODO: now available as module
      kubectl
      kubectx
      kubernetes-helm
      google-chrome
      dive
      obsidian
      docker-compose

      # Screen-share
      obs-studio
      obs-studio-plugins.wlrobs
    ];

    sessionPath = [ "$HOME/.local/bin" ];
  };

  services.mpris-proxy.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
