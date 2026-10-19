{self, ...}: {
  # Docker for all users of a host. Rootless by default, a host can switch to
  # the rootful daemon with:
  #
  # ```nix
  # dotfiles.docker.rootless = false;
  # ```
  #
  # Only one of the two daemons runs, never both.
  flake.modules.nixos.docker = {
    config,
    lib,
    ...
  }: let
    inherit (config.dotfiles.docker) rootless;
  in {
    imports = [self.modules.nixos.dotfiles-users];

    options.dotfiles.docker.rootless = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to run the rootless Docker daemon instead of the rootful one.";
    };

    config = {
      virtualisation.docker = {
        enable = !rootless;
        # All hosts are desktops, containers are started on demand
        enableOnBoot = false;
        rootless = {
          enable = rootless;
          setSocketVariable = true;
        };
      };

      # Access to the rootful socket equals root, so only grant it when needed
      dotfiles.userGroups = lib.optionals (!rootless) ["docker"];
    };
  };
}
