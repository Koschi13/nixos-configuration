{self, ...}: let
  # TODO: Should this be defined outside?
  defaultShell = "zsh";
in {
  /**
  Creates the given user(name)

  # Type

  ```
  user :: String -> Bool -> Module
  ```

  # Arguments

  username
  : The name of the user for which this aspect will be enabled

  isAdmin
  : Whether to make the user an admin (wheel group) or not.

  # Example

  ```nix
  {self, pkgs, ...}: {
    flake.modules = (self.factory.user "max" true);
  }
  ```
  */
  config.flake.factory.user = username: uid: isAdmin: {
    nixos.${username} = {
      lib,
      pkgs,
      ...
    }: {
      users.users.${username} = {
        isNormalUser = true;
        home = "/home/${username}";
        extraGroups = lib.optionals isAdmin [
          "wheel"
        ];
        shell = pkgs.${defaultShell};
        inherit uid;
      };
      programs.${defaultShell}.enable = true;

      # This wires Home-Manager into the `nixos` class, so that it is no longer
      # a standalone module, but automatically includes in nixos-rebuild.
      # The option `home-manager` is defined in home-manager.nix
      home-manager.users.${username} = {
        imports = [
          self.modules.homeManager.${username}
        ];
      };
    };

    darwin.${username} = {
      lib,
      pkgs,
      ...
    }: {
      users.users.${username} = {
        home = "/Users/${username}";
        shell = pkgs.${defaultShell};
      };
      programs.${defaultShell}.enable = true;

      # This wires Home-Manager into the `darwin` class, so that it is no longer
      # a standalone module, but automatically includes in nixos-rebuild.
      # The option `home-manager` is defined in home-manager.nix
      home-manager.users.${username} = {
        imports = [
          self.modules.homeManager.${username}
        ];
      };

      system.primaryUser = lib.mkIf isAdmin username;
    };

    homeManager.${username} = {
      home.username = username;
    };
  };
}
