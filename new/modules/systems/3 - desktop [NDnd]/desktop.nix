{inputs, ...}: {
  flake.modules.nixos.system-desktop = {
    imports = with inputs.self.modules.nixos; [
      system-server
    ];
  };

  flake.modules.darwin.system-desktop = {
    import = with inputs.self.modules.darwin; [
      system-server
    ];
  };

  flake.modules.homeManager.system-desktop = {
    imports = with inputs.self.modules.homeManager; [
      system-server
    ];
  };
}
