{self, ...}: {
  flake.modules.nixos.system-desktop = {
    imports = with self.modules.nixos; [
      system-default

      sway
      sddm
      printing
      audio
      usb
      docker
    ];

    # The desktop of every user of this host
    home-manager.sharedModules = [self.modules.homeManager.system-desktop];
  };

  flake.modules.darwin.system-desktop = {
    imports = with self.modules.darwin; [
      system-default
    ];
  };

  flake.modules.homeManager.system-desktop = {pkgs, ...}: {
    imports = with self.modules.homeManager; [
      system-default

      agents

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
      gnome
      theme-switch
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
      pinentry-gnome3
    ];

    services.gpg-agent.pinentry.package = pkgs.pinentry-gnome3;

    services.mpris-proxy.enable = true;
  };
}
