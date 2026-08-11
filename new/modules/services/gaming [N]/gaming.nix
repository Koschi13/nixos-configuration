{
  flake.modules = {
    nixos.gaming = {pkgs, ...}: {
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
    };
  };
}
