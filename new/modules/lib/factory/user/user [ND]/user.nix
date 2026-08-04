{self, ...}: let
  # TODO: Should this be defined outside?
  defaultShell = "zsh";
in {
  config.flake.factory.user = username: isAdmin: {
    nixos."${username}" = {
      lib,
      pkgs,
      ...
    }: {
      users.users."${username}" = {
        isNormalUser = true;
        home = "/home/${username}";
        extraGroups = lib.optionals isAdmin [
          "wheel"
        ];
        shell = pkgs."${defaultShell}";
      };
      programs."${defaultShell}".enable = true;

      # This wires Home-Manager into the `nixos` class, so that it is no longer
      # a standalone module, but automatically includes in nixos-rebuild.
      # The option `home-manager` is defined in home-manager.nix
      home-manager.users."${username}" = {
        imports = [
          self.modules.homeManager."${username}"
        ];
      };
    };

    darwin."${username}" = {
      lib,
      pkgs,
      ...
    }: {
      users.users."${username}" = {
        home = "/Users/${username}";
        shell = pkgs."${defaultShell}";
      };
      programs.${defaultShell}.enable = true;

      # This wires Home-Manager into the `darwin` class, so that it is no longer
      # a standalone module, but automatically includes in nixos-rebuild.
      # The option `home-manager` is defined in home-manager.nix
      home-manager.users."${username}" = {
        imports = [
          self.modules.homeManager."${username}"
        ];
      };

      system.primaryUser = lib.mkIf isAdmin "${username}";
    };

    homeManager."${username}" = {
      home.username = "${username}";
    };
  };
}
