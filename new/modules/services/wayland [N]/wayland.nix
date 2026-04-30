{self, ...}: {
  flake.modules = {
    nixos.wayland = {
      imports = with self.modules.nixos; [
        graphics
      ];

      xdg = {
        portal = {
          enable = true;
          wlr.enable = true;
        };
      };
    };
  };
}
