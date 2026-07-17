{
  /**
  Configures greetd with a default session.

  # Type

  ```
  greetd :: String -> String -> Module
  ```

  # Arguments

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
  config.flake.factory.greetd = username: desktopExecutable: {
    nixos.greetd = {
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
  };
}
