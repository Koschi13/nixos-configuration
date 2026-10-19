{self, ...}: {
  # Automounting of USB storage
  flake.modules.nixos.usb = {...}: {
    imports = [self.modules.nixos.dotfiles-users];

    services.gvfs.enable = true;
    services.udisks2.enable = true;

    # Mounts as the logged-in user through udisks2, instead of as root like
    # devmon. No tray icon, as waybar isn't started through systemd and
    # `tray.target` would never be reached.
    home-manager.sharedModules = [
      {
        services.udiskie = {
          enable = true;
          automount = true;
          notify = true;
          tray = "never";
        };
      }
    ];

    dotfiles.userGroups = ["storage"];
  };
}
