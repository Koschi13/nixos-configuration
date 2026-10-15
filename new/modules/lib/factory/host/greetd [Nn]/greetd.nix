{self, ...}: {
  /**
  Configures greetd with a default session.

  # Type

  ```
  greetd :: { hostname :: String; username :: String; windowManager :: String; } -> Module
  ```

  # Arguments

  An attribute set with:

  hostname
  : The name of the host for which this aspect will be configured for

  username
  : The name of the default user for the initial session.

  windowManager
  : The name of the desired window manager

  # Example

  ```nix
  {self, ...}: {
    flake.modules = (self.factory.greetd {
      hostname = "alpha";
      username = "max";
      windowManager = "sway";
    });
  }
  ```
  */
  config.flake.factory.greetd = {
    hostname,
    username,
    windowManager,
  }: {
    nixos.${hostname} = {pkgs, ...}: let
      pkg = pkgs.${windowManager};
      command = "${pkg}/bin/${windowManager}";
    in {
      # Make sure whatever windowManager is being used is imported
      imports = [
        self.modules.nixos.${windowManager}
      ];

      # Provides the greeter for the default session. Without it, greetd has
      # nothing to show and the graphical target never comes up.
      services.displayManager.regreet.enable = true;

      services.greetd = {
        enable = true;
        settings = {
          initial_session = {
            user = username;
            command = command;
          };
        };
      };
    };

    nixos.gnome-keyring = {
      security.pam.services.greetd.enableGnomeKeyring = true;
    };
  };
}
