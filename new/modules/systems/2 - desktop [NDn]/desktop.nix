{self, ...}: {
  flake.modules.nixos.system-desktop = {
    imports = with self.modules.nixos; [
      system-default

      sway
      sddm
      printing
      audio
      usb
    ];
  };

  flake.modules.darwin.system-desktop = {
    imports = with self.modules.darwin; [
      system-default
    ];
  };

  flake.modules.homeManager.system-desktop = {pkgs, ...}: {
    imports = with self.modules.homeManager; [
      system-default

      sway
      kanshi
      awww
      dunst
      font
      terminal
      alacritty
      firefox
      vscode
      zed
      glance
      gnome
      messengers
      office
      entertainment
    ];

    home.packages = with pkgs; [
      blueman
      gimp
      pavucontrol

      bitwarden-cli
      gnupg
      yubikey-manager
    ];

    services.mpris-proxy.enable = true;
  };
}
