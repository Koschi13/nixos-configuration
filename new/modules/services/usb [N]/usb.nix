{
  flake.modules = {
    nixos.printing = {
      services.devmon.enable = true;
      services.gvfs.enable = true;
      services.udisks2.enable = true;
    };
  };
}
