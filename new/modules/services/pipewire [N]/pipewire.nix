{lib, ...}: {
  flake.modules = {
    nixos.pipewire = {pkgs, ...}: {
      xdg.portal = {
        enable = true;
        wlr.enable = true;
      };

      services.pulseaudio.enable = lib.mkForce false;

      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };

      security.rtkit.enable = true; # For realtime acquisition

      environment.systemPackages = with pkgs; [alsa-utils];
      # TODO: audio group
    };
  };
}
