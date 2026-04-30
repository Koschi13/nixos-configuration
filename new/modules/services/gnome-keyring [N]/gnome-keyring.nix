{
  flake.modules = {
    nixos.gnome-keyring = {
      services.gnome.gnome-keyring.enable = true;
    };
  };
}
