{
  flake.modules = {
    nixos.printing = {
      services.printing.enable = true;

      # localhost:631
      services.avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
      };
    };
  };
}
