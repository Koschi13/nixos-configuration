{self, ...}: {
  # Automounting of USB storage
  flake.modules.nixos.usb = {
    config,
    lib,
    ...
  }: {
    imports = [self.modules.nixos.dotfiles-users];

    services.devmon.enable = true;
    services.gvfs.enable = true;
    services.udisks2.enable = true;

    users.users = lib.genAttrs config.dotfiles.users (_: {
      extraGroups = ["storage"];
    });
  };
}
