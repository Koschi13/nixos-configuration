{inputs, ...}: {
  # SDDM with a password login into sway. There is no autologin on purpose:
  # the password typed into the greeter is what unlocks the GNOME keyring
  # through PAM.
  flake.modules.nixos.sddm = {pkgs, ...}: let
    # SDDM opens one greeter window per output, so the login shows on all of
    # them
    theme = pkgs.where-is-my-sddm-theme.override {
      themeConfig.General = {
        showSessionsByDefault = true;
        # Kept in the git-crypt secrets for copyright reasons. It ends up in
        # the Nix store, as the sddm user can't read the home directories.
        background = "${inputs.git-crypt-secrets}/greeter-wallpaper.jpg";
        backgroundMode = "aspect";
      };
    };
  in {
    services.displayManager = {
      sddm = {
        enable = true;
        # Runs the greeter in Weston instead of an X server
        wayland.enable = true;
        theme = "where_is_my_sddm_theme";
        extraPackages = [theme];
      };
      defaultSession = "sway";

      # Lists the session in the greeter. Only the `.desktop` entry is taken
      # from the package, it runs whatever `sway` is on the user's PATH, as
      # SDDM starts the session through a login shell.
      sessionPackages = [pkgs.sway];
    };

    # SDDM looks for themes in /run/current-system/sw/share/sddm/themes
    environment.systemPackages = [theme];
  };
}
