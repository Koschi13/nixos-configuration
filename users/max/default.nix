{
  config,
  pkgs,
  firefox-addons,
  ...
}:

{
  imports = [
    ../_modules/alacritty.nix
    ../_modules/direnv.nix
    ../_modules/dunst.nix
    ../_modules/firefox.nix
    ../_modules/git.nix
    ../_modules/gnome.nix
    ../_modules/gpg/default.nix
    ../_modules/homemanager.nix
    ../_modules/nixpkgs.nix
    ../_modules/nvim/default.nix
    ../_modules/rofi/default.nix
    ../_modules/sway/default.nix
    ../_modules/swww.nix
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
      nerd-fonts.noto  # alt until dejavu is fixed

      # tools
      ripgrep
      nvtopPackages.full

      # encryption
      bitwarden
      bitwarden-cli
      git-crypt
      gnupg
      yubikey-manager

      # Messengers
      discord
      element-desktop
      signal-desktop
      tdesktop

      # other
      pavucontrol

      # entertainment
      vlc
      spotify
    ];

    sessionPath = [ "$HOME/.local/bin" ];
  };

  services.mpris-proxy.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
