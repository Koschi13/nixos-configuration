{ config, pkgs, firefox-addons, rootPath, ... }:

let

  aws_vars = import "${rootPath}/.secrets/aws_vars.nix";

in {
  imports = [
    ../_modules/zsh/default.nix
    ../_modules/firefox.nix
    ../_modules/nvim.nix
    ../_modules/gnome.nix
    ../_modules/gpg/default.nix
    ../_modules/homemanager.nix
    ../_modules/nixpkgs.nix
    ../_modules/hyprland/default.nix
    ../_modules/rofi/default.nix
    ../_modules/dunst.nix
    ../_modules/waybar.nix
    ../_modules/scripts/default.nix
    ../_modules/direnv.nix
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
      alacritty

      # coding
      jetbrains.pycharm-professional

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
      pavucontrol
      google-chrome

      # work
      _1password-gui
      slack
      awscli2
      kubectl
      kubectx
      podman-compose
    ];

    file = {
      ".config/alacritty/alacritty.yaml".text = ''
        env:
          TERM: xterm-256color
      '';
    };

    sessionPath = [ "$HOME/.local/bin" ];

    sessionVariables = {
      AWS_PROFILE = aws_vars.env.AWS_PROFILE;
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
