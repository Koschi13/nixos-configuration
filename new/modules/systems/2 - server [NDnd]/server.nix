{inputs, ...}: {
  flake.modules.nixos.system-server = {
    imports = with inputs.self.modules.nixos; [
      system-default
    ];
  };

  flake.modules.darwin.system-server = {
    import = with inputs.self.modules.darwin; [
      system-default
    ];
  };

  flake.modules.homeManager.system-server = {
    imports = with inputs.self.modules.homeManager; [
      system-default
    ];
  };
}
