{self, ...}: {
  # Everything needed for gaming on Linux, for all users of a host
  flake.modules.nixos.gaming = {
    config,
    lib,
    pkgs,
    ...
  }: {
    imports = [self.modules.nixos.dotfiles-users];

    programs.gamemode.enable = true;

    boot.kernelModules = ["ntsync"];
    environment.systemPackages = with pkgs; [mesa];

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      gamescopeSession = {
        enable = true;
      };
      package = pkgs.steam.override {
        extraLibraries = pkgs:
          with pkgs; [
            gamemode
          ];
        extraEnv = {
          LD_PRELOAD = "${pkgs.gamemode.lib}/lib/libgamemode.so";
        };
      };

      localNetworkGameTransfers.openFirewall = true;
    };

    users.users = lib.genAttrs config.dotfiles.users (_: {
      extraGroups = ["gamemode"];
    });

    home-manager.sharedModules = with self.modules.homeManager; [mangohud minecraft];
  };
}
