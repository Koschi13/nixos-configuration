{
  flake.modules = {
    nixos.gnome-keyring = {pkgs, ...}: {
      services.gnome.gnome-keyring.enable = true;

      security.pam.services.login.enableGnomeKeyring = true;
      services.dbus.packages = with pkgs; [
        gnome-keyring
        gcr
      ];
    };
  };
}
