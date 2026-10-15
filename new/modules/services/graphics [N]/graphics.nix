{
  flake.modules.nixos.graphics = {pkgs, ...}: {
    hardware.graphics.enable = true;

    xdg = {
      portal = {
        config.common.default = "gtk";
        extraPortals = with pkgs; [xdg-desktop-portal-gtk];
      };
    };
  };
}
