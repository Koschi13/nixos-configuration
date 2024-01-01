{ config, pkgs, firefox-addons, ... }:

{
  imports = [
    ../_modules/zsh.nix
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
      slack
    ];

    file = {
      ".config/alacritty/alacritty.yaml".text = ''
        env:
          TERM: xterm-256color
      '';
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
