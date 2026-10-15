{self, ...}: {
  # Automounting of USB storage
  flake.modules.nixos.usb = {...}: {
    imports = [self.modules.nixos.dotfiles-users];

    services.devmon.enable = true;
    services.gvfs.enable = true;
    services.udisks2.enable = true;

    dotfiles.userGroups = ["storage"];
  };
}
