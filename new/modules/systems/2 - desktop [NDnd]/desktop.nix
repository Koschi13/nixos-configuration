{self, ...}: {
  flake.modules.nixos.system-desktop = {
    imports = with self.modules.nixos; [
      system-default

      sway
      xserver
      printing
      usb
    ];
  };

  flake.modules.darwin.system-desktop = {
    imports = with self.modules.darwin; [
      system-default
    ];
  };

  flake.modules.homeManager.system-desktop = {
    imports = with self.modules.homeManager; [
      system-default

      sway
    ];
  };
}
