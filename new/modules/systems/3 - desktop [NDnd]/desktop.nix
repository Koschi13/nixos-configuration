{inputs, ...}: {
  flake.modules.nixos.system-default = {
    imports = with inputs.self.modules.nixos; [
      system-server
    ];
  };

  flake.modules.darwin.system-default = {
    import = with inputs.self.modules.darwin; [
      system-server
    ];
  };

  flake.modules.homeManager.system-default = {
    imports = with inputs.self.modules.homeManager; [
      system-server
    ];
  };
}
