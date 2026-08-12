{
  flake.modules = {
    nixos.rgb = {pkgs, ...}: {
      services.hardware.openrgb.enable = true;
      environment.systemPackages = with pkgs; [openrgb-with-all-plugins];
    };

    # Add to startup if sway is used
    homeManager.sway = {
      wayland.windowManager.sway = {
        config = {
          startup = [
            {
              # TODO: provide file via this repo
              command = "which openrgb && openrgb --startminimized --profile /home/max/.config/OpenRGB/rgb.orp";
            }
          ];
        };
      };
    };
  };
}
