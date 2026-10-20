{
  flake.modules = {
    nixos.pipewire = {
      lib,
      pkgs,
      ...
    }: {
      services.pulseaudio.enable = lib.mkForce false;

      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };

      security.rtkit.enable = true; # For realtime acquisition

      # The audio stack is made of global user units, so it would also start
      # for system users like the greeter, whose home /var/empty isn't writable
      systemd.user = let
        skipSystemUsers.unitConfig.ConditionUser = "!@system";
      in {
        sockets = lib.genAttrs ["pipewire" "pipewire-pulse"] (_: skipSystemUsers);
        services = lib.genAttrs ["pipewire" "pipewire-pulse" "wireplumber"] (_: skipSystemUsers);
      };

      environment.systemPackages = with pkgs; [alsa-utils];
    };
  };
}
