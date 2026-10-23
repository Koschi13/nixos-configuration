{
  flake.modules.nixos.graphics = {pkgs, ...}: {
    # Deduplicates the module, see `dotfiles-users` in `lib/users [N]/users.nix`
    key = "graphics";

    hardware.graphics.enable = true;

    xdg = {
      portal = {
        config.common.default = "gtk";
        extraPortals = with pkgs; [xdg-desktop-portal-gtk];
      };
    };
  };
}
