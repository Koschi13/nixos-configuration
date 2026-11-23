{self, ...}: {
  flake.modules.nixos.wow = {
    imports = [self.modules.nixos.gaming];

    home-manager.sharedModules = [self.modules.homeManager.wow];
  };

  flake.modules.homeManager.wow = {pkgs, ...}: {
    home = {
      packages = with pkgs; [
        teamspeak6-client
        wowup-cf
      ];
    };
  };
}
