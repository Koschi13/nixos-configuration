{self, ...}: {
  flake.modules = {
    nixos.sway = {
      imports = with self.modules.nixos; [
        pipewire
        gnome-keyring
        wayland
      ];

      # See https://github.com/hyprwm/Hyprland/issues/2727
      # Need for Swaylock to accept password
      security.pam.services.swaylock = {};
      security.polkit.enable = true;

      xdg = {
        portal = {
          wlr.enable = true;
        };
      };
    };
    homeManager.sway = {
    };
  };
}
