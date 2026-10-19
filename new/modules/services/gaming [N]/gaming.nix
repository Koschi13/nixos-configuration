{self, ...}: {
  # Everything needed for gaming on Linux, for all users of a host
  flake.modules.nixos.gaming = {pkgs, ...}: {
    # Aspects like `minecraft` import gaming as well, see `dotfiles-users` for
    # why the key is needed.
    key = "gaming";

    imports = [self.modules.nixos.dotfiles-users];

    # Enable it per game with the Steam launch option `gamemoderun %command%`
    programs.gamemode.enable = true;

    boot.kernelModules = ["ntsync"];
    environment.systemPackages = with pkgs; [mesa];

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      gamescopeSession = {
        enable = true;
      };
      # Makes `gamemoderun` usable inside the Steam runtime
      extraPackages = with pkgs; [gamemode];

      localNetworkGameTransfers.openFirewall = true;
    };

    dotfiles.userGroups = ["gamemode"];

    home-manager.sharedModules = [self.modules.homeManager.mangohud];
  };
}
