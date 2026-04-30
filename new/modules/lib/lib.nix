{
  inputs,
  lib,
  ...
}: {
  # Helper functions for creating system / home-manager configurations
  options.flake.lib = lib.mkOption {
    type = lib.types.attrsOf lib.types.unspecified;
    default = {};
  };

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
  flake.nixosConfigurations = inputs.self.lib.mkNixos "x86_64-linux" "alpha";
  ```
  */
  config.flake.lib = {
    mkNixos = system: name: {
      ${name} = inputs.nixpkgs.lib.nixosSystem {
        modules = [
          inputs.self.modules.nixos.${name}
          {nixpkgs.hostPlatform = lib.mkDefault system;}
        ];
      };
    };

    mkDarwin = system: name: {
      ${name} = inputs.nix-darwin.lib.darwinSystem {
        modules = [
          inputs.self.modules.darwin.${name}
          {nixpkgs.hostPlatform = lib.mkDefault system;}
        ];
      };
    };

    /**
    Configures Home-Manager for the given (user)name.

    This will automatically configure `pkgs` and the `modules` available
    to that user. So all `homeManager.<name>` configurations are imported.

    # Type

    ```
    mkHomeManager :: String -> String -> Module
    ```

    # Arguments

    system
    : The type of system this is configured for. See systems.nix.

    name
    : The name of the user the configuration is for. This is important to
      get right, as it is responsible for importing all the user specific
      configuration via `homeManager.<name>`.

    # Example

    ```nix
    flake.homeConfigurations = inputs.self.lib.mkHomeManager "x86_64-linux" "max";
    ```
    */
    mkHomeManager = system: name: {
      ${name} = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = inputs.nixpkgs.legacyPackages.${system};
        modules = [
          inputs.self.modules.homeManager.${name}
          {nixpkgs.config.allowUnfree = true;} # TODO: do we want this to be the default?
        ];
      };
    };
  };
}
