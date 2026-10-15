{
  inputs,
  self,
  lib,
  ...
}: {
  # Helper functions for creating system / home-manager configurations
  options.flake.lib = lib.mkOption {
    type = lib.types.attrsOf lib.types.unspecified;
    default = {};
  };

  config.flake.lib = {
    /**
    Configures NixOs for the given (host)name.

    This will import all `nixos.<name>` configurations for that host.

    # Type

    ```
    mkNixos :: String -> String -> Module
    ```

    # Arguments

    system
    : The type of system this is configured for. See systems.nix.

    name
    : The name of the host the configuration is for. This is important to
      get right, as it is responsible for importing all the host specific
      configuration via `nixos.<name>`.

    # Example

    ```nix
    flake.nixosConfigurations = self.lib.mkNixos "x86_64-linux" "alpha";
    ```
    */
    mkNixos = system: name: {
      ${name} = inputs.nixpkgs.lib.nixosSystem {
        modules = [
          self.modules.nixos.${name}
          {nixpkgs.hostPlatform = lib.mkDefault system;}
        ];
      };
    };

    /**
    Configures Nix for the given (host)name on Darwin.

    This will import all `darwin.<name>` configurations for that host.

    # Type

    ```
    mkDarwin :: String -> String -> Module
    ```

    # Arguments

    system
    : The type of system this is configured for. See systems.nix.

    name
    : The name of the host the configuration is for. This is important to
      get right, as it is responsible for importing all the host specific
      configuration via `darwin.<name>`.

    # Example

    ```nix
    flake.nixosConfigurations = self.lib.mkDarwin "aarch64-darwin" "mac";
    ```
    */
    mkDarwin = system: name: {
      ${name} = inputs.nix-darwin.lib.darwinSystem {
        modules = [
          self.modules.darwin.${name}
          {nixpkgs.hostPlatform = lib.mkDefault system;}
        ];
      };
    };
  };
}
