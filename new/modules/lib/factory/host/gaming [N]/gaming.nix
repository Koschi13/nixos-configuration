{self, ...}: {
  /**
  Sets up everything needed for gaming on Linux for the given user(name)

  # Type

  ```
  usb :: String -> Module
  ```

  # Arguments

  username
  : The name of the user for which this aspect will be enabled

  # Example

  ```nix
  {self, ...}: {
    flake.modules.nixos.<name> = {
      imports = [(self.factory.gaming "max")];
    }
  }
  ```
  */
  config.flake.factory.gaming = username: {pkgs, ...}: {
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

    users.users.${username}.extraGroups = ["gamemode"];

    home-manager.users.${username} = {
      imports = with self.modules.homeManager; [mangohud];
    };
  };
}
