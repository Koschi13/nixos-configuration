{
  flake.modules = {
    nixos.rgb = {
      config,
      pkgs,
      ...
    }: let
      hostName = config.networking.hostName;
    in {
      services.hardware.openrgb.enable = true;
      environment.systemPackages = with pkgs; [openrgb-with-all-plugins];

      # Apply the lighting profile of this host when sway starts. The profile
      # is created in the OpenRGB UI and saved as `<hostname>.orp`.
      home-manager.sharedModules = [
        ({config, ...}: {
          wayland.windowManager.sway.config.startup = [
            {
              command = "openrgb --startminimized --profile ${config.xdg.configHome}/OpenRGB/${hostName}.orp";
            }
          ];
        })
      ];
    };
  };
}
