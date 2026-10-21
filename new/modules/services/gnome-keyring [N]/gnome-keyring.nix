{
  flake.modules = {
    nixos.gnome-keyring = {pkgs, ...}: {
      # Deduplicates the module, see `dotfiles-users` in `lib/users [N]/users.nix`
      key = "gnome-keyring";

      services.gnome.gnome-keyring.enable = true;

      # Also unlocks the keyring when logging in through SDDM, as its PAM
      # service includes `login`
      security.pam.services.login.enableGnomeKeyring = true;
      services.dbus.packages = with pkgs; [
        gnome-keyring
        gcr_4
      ];
    };
  };
}
