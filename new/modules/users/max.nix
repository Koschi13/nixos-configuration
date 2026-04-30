{
  self,
  lib,
  ...
}: {
  flake.modules = lib.mkMerge [
    (self.factory.user "max" true)
    {
      nixos.max = {
        imports = with self.modules.nixos; [
          # developmentEnvironment
        ];
        users.users.max = {
          group = "audio";
        };
      };

      darwin.max = {
        imports = with self.modules.darwin; [
          # drawingApps
          # developmentEnvironment
        ];
      };

      homeManager.max = {pkgs, ...}: {
        imports = with self.modules.homeManager; [
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
