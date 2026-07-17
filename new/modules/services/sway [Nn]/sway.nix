{self, ...}: {
  flake.modules = {
    nixos.sway = {
      imports = with self.modules.nixos; [
        pipewire
      ];
    };
    homeManager.sway = {
    };
  };
}
