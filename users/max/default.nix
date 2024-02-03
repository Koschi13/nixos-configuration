{ config, pkgs, firefox-addons, ... }:

{
  imports = [
    ../_modules/zsh/default.nix
    ../_modules/firefox.nix
    ../_modules/nvim/default.nix
    ../_modules/homemanager.nix
    ../_modules/nixpkgs.nix
    ../_modules/gnome.nix
    ../_modules/gpg/default.nix
    ../_modules/rofi/default.nix
    ../_modules/dunst.nix
    ../_modules/waybar/default.nix
    ../_modules/direnv.nix
    ../_modules/i3/default.nix
    ../_modules/swww.nix
    ../_modules/alacritty.nix
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
      nixfmt
      jetbrains-toolbox

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
    ];

    sessionPath = [ "$HOME/.local/share/JetBrains/Toolbox/scripts" ];
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
