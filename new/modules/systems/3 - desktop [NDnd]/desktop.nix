{self, ...}: {
  flake.modules.nixos.system-desktop = {
    imports = with self.modules.nixos; [
      system-server

      sway
    ];
  };

  flake.modules.darwin.system-desktop = {
    imports = with self.modules.darwin; [
      system-server
    ];
  };

  flake.modules.homeManager.system-desktop = {
    imports = with self.modules.homeManager; [
      system-server

      sway
    ];
  };
}
