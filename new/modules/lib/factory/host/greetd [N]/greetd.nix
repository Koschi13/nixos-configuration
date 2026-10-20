{self, ...}: {
  /**
  Configures greetd with a password login into the given window manager.

  There is no autologin on purpose: the password typed into the greeter is
  what unlocks the GNOME keyring through PAM.

  # Type

  ```
  greetd :: { hostname :: String; windowManager :: String; primaryOutput :: String?; wallpaper :: (Path | String)?; } -> { nixos.<hostname> :: Module; }
  ```

  # Arguments

  An attribute set with:

  hostname
  : The name of the host for which this aspect will be configured for


  windowManager
  : The name of the desired window manager


  primaryOutput
  : Optional. The sway output the greeter is shown on, preferably as
    "make model serial" like in kanshi. Other outputs only show the wallpaper.


  wallpaper
  : Optional. The image behind the greeter and on the other outputs. It ends
    up in the Nix store, as the greeter user can't read the home directories.

  # Example

  ```nix
  {self, inputs, ...}: {
    flake.modules = (self.factory.greetd {
      hostname = "alpha";
      windowManager = "sway";
      primaryOutput = "AOC U34G2G4R3 0x00002347";
      wallpaper = "${inputs.git-crypt-secrets}/greeter-wallpaper.jpg";
    });
  }
  ```
  */
  config.flake.factory.greetd = {
    hostname,
    windowManager,
    primaryOutput ? null,
    wallpaper ? null,
  }: {
    nixos.${hostname} = {
      pkgs,
      lib,
      config,
      ...
    }: let
      # The greeter runs in its own sway instead of cage, as cage stretches
      # the greeter over all outputs. Sway shows it on a single output and
      # leaves the others to the wallpaper.
      greeterSwayConfig = pkgs.writeText "greeter-sway-config" ''
        xwayland disable
        default_border none
        swaybg_command ${lib.getExe pkgs.swaybg}

        ${lib.optionalString (wallpaper != null) "output * bg ${wallpaper} fill"}
        ${lib.optionalString (primaryOutput != null) ''focus output "${primaryOutput}"''}

        exec "${lib.getExe config.services.displayManager.regreet.package}; swaymsg exit"
      '';
    in {
      # Make sure whatever windowManager is being used is imported
      imports = [
        self.modules.nixos.${windowManager}
      ];

      # Provides the greeter for the default session. Without it, greetd has
      # nothing to show and the graphical target never comes up. It remembers
      # the last user and session.
      services.displayManager.regreet = {
        enable = true;
        settings = {
          GTK.application_prefer_dark_theme = true;
          background = lib.mkIf (wallpaper != null) {
            path = "${wallpaper}";
            fit = "Cover";
          };
        };
      };

      services.greetd = {
        enable = true;
        settings.default_session.command = "${pkgs.dbus}/bin/dbus-run-session ${lib.getExe pkgs.sway} --config ${greeterSwayConfig}";
      };

      # Lists the session in the greeter. Only the `.desktop` entry is taken
      # from the package, it runs whatever `${windowManager}` is on the user's
      # PATH, as greetd sources /etc/profile before starting the session.
      services.displayManager.sessionPackages = [pkgs.${windowManager}];
    };
  };
}
