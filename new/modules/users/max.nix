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
    # Install android-tools and add user to group
    (self.factory.android username)
    # Setup audio
    (self.factory.audio username)
    {
      nixos.max = {
        imports = with self.modules.nixos; [
          # developmentEnvironment
        ];

        users.users.${username}.group = "users";
      };

      darwin.max = {
        imports = with self.modules.darwin; [
          # drawingApps
          # developmentEnvironment
        ];
      };

      homeManager.max = {pkgs, ...}: {
        imports = with self.modules.homeManager; [
          system-default # default setup of homeManager system
          # adminTools
          # vscode
          # passwordManager
        ];
        home.packages = with pkgs; [
          #_mediainfo
        ];
      };
    }
  ];
}
