{
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

  desktopExecutable
  : The path to the executable.

  # Example

  ```nix
  {self, pkgs, ...}: {
    flake.modules = (self.factory.greetd "max" "${pkgs.sway}/bin/sway");
  }
  ```
  */
  config.flake.factory.greetd = hostname: username: desktopExecutable: {
    nixos.${hostname} = {
      services.greetd = {
        enable = true;
        settings = {
          initial_session = {
            user = username;
            command = desktopExecutable;
          };
        };
      };
    };

    nixos.gnome-keyring = {
      security.pam.services.greetd.enableGnomeKeyring = true;
    };
  };
}
