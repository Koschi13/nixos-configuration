{pkgs, ...}: {
  imports = [
    ../_modules/alacritty.nix
    ../_modules/direnv.nix
    ../_modules/dunst.nix
    ../_modules/firefox.nix
    ../_modules/git.nix
    ../_modules/gnome.nix
    ../_modules/gpg/default.nix
    ../_modules/homemanager.nix
    ../_modules/mangohud.nix
    ../_modules/navi/default.nix
    ../_modules/nh.nix
    ../_modules/nixpkgs.nix
    ../_modules/nvim/default.nix
    ../_modules/rofi/default.nix
    ../_modules/sway/default.nix
    ../_modules/swww/default.nix
    ../_modules/vscode/default.nix
    ../_modules/waybar/default.nix
    ../_modules/zsh/default.nix
  ];

  # Enable fonts
  fonts = {
    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = ["NotoSerif Nerd Font"];
        sansSerif = ["NotoSans Nerd Font"];
        monospace = ["NotoSansM Nerd Font Mono"];
      };
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
      # fonts
      nerd-fonts.dejavu-sans-mono
      nerd-fonts.noto # alt until dejavu is fixed

      # tools
      ripgrep
      fd
      nvtopPackages.full
      blueman
      gimp

      # encryption
      bitwarden
      bitwarden-cli
      git-crypt
      gnupg
      yubikey-manager
      protonvpn-gui

      # Messengers
      discord
      element-desktop
      signal-desktop
      tdesktop

      # other
      pavucontrol

      # office
      pdfsam-basic

      # entertainment
      vlc
      spotify
    ];

    sessionPath = ["$HOME/.local/bin"];
  };

  services.mpris-proxy.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
