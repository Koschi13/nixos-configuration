{
  flake.modules = {
    nixos.rgb = {
      config,
      pkgs,
      ...
    }: let
      hostName = config.networking.hostName;
      openrgb = pkgs.openrgb-with-all-plugins;
    in {
      services.hardware.openrgb.enable = true;
      environment.systemPackages = [openrgb];

      # Apply the lighting profile of this host when sway starts. The profile
      # is created in the OpenRGB UI and saved as `<hostname>.orp`.
      home-manager.sharedModules = [
        ({config, ...}: {
          wayland.windowManager.sway.config.startup = [
            {
              command = "${openrgb}/bin/openrgb --startminimized --profile ${config.xdg.configHome}/OpenRGB/${hostName}.orp";
            }
          ];
        })
      ];
    };
  };
}
