{
  flake.modules.nixos.graphics = {pkgs, ...}: {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    xdg = {
      portal = {
        config.common.default = "gtk";
        extraPortals = with pkgs; [xdg-desktop-portal-gtk];
      };
    };
  };
}
