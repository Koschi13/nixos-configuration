{self, ...}: {
  flake.modules.nixos.system-server = {
    imports = with self.modules.nixos; [
      system-default
    ];
  };

  flake.modules.darwin.system-server = {
    imports = with self.modules.darwin; [
      system-default
    ];
  };

  flake.modules.homeManager.system-server = {
    imports = with self.modules.homeManager; [
      system-default
    ];
  };
}
