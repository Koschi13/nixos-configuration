{ config, pkgs, firefox-addons, rootPath, lib, ... }:

let
  # Override Obsidian's electron_25 version to not include any vulnerabilities
  # This is needed to even be able to install and use the package
  obsidian = lib.throwIf (lib.versionOlder "1.5.3" pkgs.obsidian.version)
    "Obsidian no longer requires EOL Electron" (pkgs.obsidian.override {
      electron = pkgs.electron_25.overrideAttrs (_: {
        preFixup =
          "patchelf --add-needed ${pkgs.libglvnd}/lib/libEGL.so.1 $out/bin/electron"; # https://github.com/NixOS/nixpkgs/issues/272912
        meta.knownVulnerabilities =
          [ ]; # https://github.com/NixOS/nixpkgs/issues/273611
      });
    });

in {
  imports = [
    ../_modules/zsh/default.nix
    ../_modules/firefox.nix
    ../_modules/nvim/default.nix
    ../_modules/gnome.nix
    ../_modules/gpg/default.nix
    ../_modules/homemanager.nix
    ../_modules/nixpkgs.nix
    #../_modules/hyprland/default.nix
    ../_modules/rofi/default.nix
    ../_modules/dunst.nix
    ../_modules/waybar/default.nix
    ../_modules/direnv.nix
    ../_modules/sway/default.nix
    ../_modules/swww.nix
    ../_modules/alacritty.nix
    ../_modules/librewolf.nix
  ];

  home = {
    # Home Manager needs a bit of information about you and the
    # paths it should manage.
    username = "max";
    homeDirectory = "/home/max";

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "23.05";

    packages = with pkgs;
      [
        # tools
        ripgrep
        (nerdfonts.override { fonts = [ "DejaVuSansMono" ]; })
        zip
        unzip
        blueman

        # coding
        jetbrains.pycharm-professional
        jetbrains.rust-rover
        android-studio
        nixfmt # TODO provide via dev shell?

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
        firefox-wayland
        spotify
        pavucontrol

        # work
        _1password-gui
        slack
        awscli2 # TODO: now available as module
        kubectl
        kubectx
        podman-compose
        kubernetes-helm
        google-chrome
        dive
      ] ++ [ obsidian ];

    sessionPath = [ "$HOME/.local/bin" ];

    sessionVariables = {
      TERMINAL = "alacritty";
      BROWSER = "firefox";
    };
  };

  services.mpris-proxy.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
