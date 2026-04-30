{inputs, ...}: let
  home-manager-config = {...}: {
    home-manager = {
      # See https://github.com/nix-community/home-manager/blob/master/nixos/common.nix
      # TODO: Review all and use or delete this
    };
  };
in {
  # Automatic setup for the `nixos` class
  flake.modules.nixos.home-manager = {
    imports = [
      inputs.home-manager.nixosModules.home-manager
      home-manager-config
    ];
  };

  # Automatic setup for the `darwin` class
  flake.modules.darwin.home-manager = {
    imports = [
      inputs.home-manager.darwinModules.home-manager
      home-manager-config
    ];
  };
}
