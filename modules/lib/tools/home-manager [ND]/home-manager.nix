{inputs, ...}: let
  home-manager-config = {...}: {
    home-manager = {
      # See https://github.com/nix-community/home-manager/blob/master/nixos/common.nix
      # TODO: Review all and use or delete this
      useGlobalPkgs = true;
      useUserPackages = true;
      # Activate inside the user's systemd session (like standalone HM did) instead
      # of a boot-time system service. Otherwise `importGpgKeys` spawns a keyboxd
      # before /run/user/$UID exists; it binds its socket in ~/.gnupg and holds
      # the pubring.db lock forever, so every later `gpg` call hangs on the lock.
      startAsUserService = true;
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
