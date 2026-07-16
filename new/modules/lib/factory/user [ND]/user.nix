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
