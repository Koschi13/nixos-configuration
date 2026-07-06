{pkgs, ...}: {
  imports = [
    ../_modules/agents/default.nix
    ../_modules/alacritty.nix
    ../_modules/awww/default.nix
    ../_modules/direnv.nix
    ../_modules/dunst.nix
    ../_modules/firefox.nix
    ../_modules/ghostty.nix
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
    ../_modules/scripts/default.nix
    ../_modules/ssh.nix
    ../_modules/sway/default.nix
    ../_modules/tmux.nix
    ../_modules/vscode/default.nix
    ../_modules/waybar/default.nix
    ../_modules/zed.nix
    ../_modules/zsh/default.nix
  ];

  # Enable fonts
  fonts = {
    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = ["Lilex Nerd Font Propo"];
        sansSerif = ["Lilex Nerd Font"];
        monospace = ["Lilex Nerd Font Mono"];
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
      nerd-fonts.lilex

      # tools
      ripgrep
      fd
      zip
      unzip
      blueman
      timewarrior
      bruno # postman alternative

      # coding
      opencode
      opencode-desktop

      # encryption
      #bitwarden-desktop  # disabled because of https://github.com/NixOS/nixpkgs/issues/526914
      bitwarden-cli
      git-crypt
      gnupg
      yubikey-manager
      openvpn # Workaround for nm-openvpn not working

      # Messengers
      element-desktop
      signal-desktop
      telegram-desktop

      # other
      cifs-utils
      nfs-utils
      pavucontrol
      gimp
      libreoffice

      # work
      slack
      google-chrome
      dive
      obsidian
      docker-compose

      # entertainment
      spotify
      easyeffects
    ];

    sessionPath = ["$HOME/.local/bin"];
  };

  services.mpris-proxy.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
