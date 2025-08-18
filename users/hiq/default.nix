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
    ../_modules/librewolf.nix
    ../_modules/navi/default.nix
    ../_modules/nh.nix
    ../_modules/nixpkgs.nix
    ../_modules/nvim/hiq.nix
    ../_modules/rofi/default.nix
    ../_modules/ssh.nix
    ../_modules/sway/default.nix
    ../_modules/swww/default.nix
    ../_modules/vscode/default.nix
    ../_modules/waybar/default.nix
    ../_modules/zsh/default.nix
    ../_modules/vscode/default.nix
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
      zip
      unzip
      blueman
      timewarrior
      bruno # postman alternative
      vault

      # coding
      jetbrains.pycharm-professional
      jetbrains.gateway
      android-studio

      # encryption
      bitwarden
      bitwarden-cli
      git-crypt
      gnupg
      yubikey-manager
      openvpn # Workaround for nm-openvpn not working

      # Messengers
      element-desktop
      signal-desktop
      tdesktop

      # other
      cifs-utils
      nfs-utils
      pavucontrol

      # work
      _1password-gui
      slack
      awscli2
      ssm-session-manager-plugin # needed for SSM
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

      # entertainment
      spotify
    ];

    sessionPath = ["$HOME/.local/bin"];
  };

  services.mpris-proxy.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
