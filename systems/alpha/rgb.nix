{pkgs, ...}: {
  services.hardware.openrgb.enable = true;
  environment.systemPackages = with pkgs; [openrgb-with-all-plugins];

  systemd.services.openrgbProfileLoader = {
    description = "Openrgb profile loader";
    after = ["multi-user.target" "openrgb.service"]; # openrgb.service is provided by `services.hardware.openrgb`
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.openrgb-with-all-plugins}/bin/openrgb --startminimized --profile /home/max/.config/OpenRGB/alpha.orp";
    };
    enable = true;
  };
}
