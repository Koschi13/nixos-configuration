{inputs, ...}: {
  flake.modules.nixos.system-default = {
    imports = with inputs.self.modules.nixos; [
      system-default
    ];
  };

  flake.modules.darwin.system-default = {
    import = with inputs.self.modules.darwin; [
      system-default
    ];
  };

  flake.modules.homeManager.system-default = {
    imports = with inputs.self.modules.homeManager; [
      system-default
    ];
  };
}
