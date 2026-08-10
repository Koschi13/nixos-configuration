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
    flake.homeConfigurations = self.lib.mkHomeManager "x86_64-linux" "max";
    ```
    */
    mkHomeManager = system: name: {
      ${name} = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = inputs.nixpkgs.legacyPackages.${system};
        modules = [
          self.modules.homeManager.${name}
          {nixpkgs.config.allowUnfree = true;} # TODO: do we want this to be the default?
        ];
      };
    };
  };
}
