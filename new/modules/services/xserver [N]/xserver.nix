{self, ...}: {
  flake.modules.nixos.xserver = {pkgs, ...}: {
    imports = with self.modules.nixos; [
      graphics
    ];

    xserver = {
      enable = true;
      excludePackages = [pkgs.xterm];
    };
  };
}
