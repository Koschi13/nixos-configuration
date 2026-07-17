{
  flake.modules = {
    nixos.pipewire = {
      xdg.portal = {
        enable = true;
        wlr.enable = true;
      };
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        pulse.enable = true;
      };
    };
  };
}
