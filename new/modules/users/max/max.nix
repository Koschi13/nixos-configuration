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
        users.users.${username}.group = "users";
      };

      # darwin.max = {
      #   imports = with self.modules.darwin; [
      #   ];
      # };

      homeManager.max = {pkgs, ...}: {
        imports = with self.modules.homeManager; [
          system-desktop
          mistral-vibe
        ];

        home.packages = with pkgs; [
          nvtopPackages.full
          android-tools
          android-studio
          proton-vpn
          discord
          telegram-desktop
          pdfsam-basic
          vlc
          calibre
          mp3cat
          puddletag
        ];
      };
    }
  ];
}
