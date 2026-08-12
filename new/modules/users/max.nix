{
  self,
  lib,
  ...
}: let
  username = "max";
in {
  flake.modules = lib.mkMerge [
    # Create the user in the system
    (self.factory.user username 1000 true)
    {
      nixos.max = {
        imports = with self.modules.nixos; [
          # developmentEnvironment
        ];

        users.users.${username}.group = "users";
      };

      # darwin.max = {
      #   imports = with self.modules.darwin; [
      #   ];
      # };

      homeManager.max = {pkgs, ...}: {
        imports = with self.modules.homeManager; [
          system-default # default setup of homeManager system

          sway
          neovim
        ];
      };
    }
  ];
}
