{
  flake.modules = {
    nixos.gnome-keyring = {
      config,
      lib,
      pkgs,
      ...
    }: {
      services.gnome.gnome-keyring.enable = true;

      security.pam.services.login.enableGnomeKeyring = true;
      # Unlock the keyring when logging in through the greeter
      security.pam.services.greetd.enableGnomeKeyring = lib.mkIf config.services.greetd.enable true;
      services.dbus.packages = with pkgs; [
        gnome-keyring
        gcr_4
      ];
    };
  };
}
