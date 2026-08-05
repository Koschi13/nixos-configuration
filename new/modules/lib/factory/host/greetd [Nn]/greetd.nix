{self, ...}: {
  /**
  Configures greetd with a default session.

  # Type

  ```
  greetd :: String -> String -> String -> Module
  ```

  # Arguments

  hostname
  : The name of the host for which this aspect will be configured for

  username
  : The name of the default user for the initial session.

  windowManager
  : The name of the desired window manager

  # Example

  ```nix
  {self, pkgs, ...}: {
    flake.modules = (self.factory.greetd "max" "sway");
  }
  ```
  */
  config.flake.factory.greetd = hostname: username: windowManager: {
    nixos.${hostname} = {pkgs, ...}: let
      pkg = pkgs.${windowManager};
      command = "${pkg}/bin/${windowManager}";
    in {
      # Make sure whatever windowManager is being used is imported
      imports = [
        self.modules.nixos.${windowManager}
      ];

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

    homeManager.${hostname} = {
      imports = [
        self.modules.homeManager.${windowManager}
      ];
    };
  };
}
