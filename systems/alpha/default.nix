{pkgs, ...}: {
  imports = [
    ../default.nix
    ./android.nix
    ./cache.nix
    ./gaming.nix
    ./hardware-configuration.nix
    ./mounts.nix
    # ./ollama.nix
    ./radeon.nix
    ./rgb.nix
    ./virtualization.nix
  ];

  networking = {
    hostName = "alpha";
  };

  xdg = {
    portal = {
      wlr.enable = true;
    };
  };

  services.displayManager.regreet.enable = true;
  services.greetd = {
    enable = true;
    settings = {
      initial_session = {
        user = "max";
        command = "${pkgs.sway}/bin/sway";
      };
    };
  };

  services.logind.settings.Login = {
    RuntimeDirectorySize = "6G";
  };

  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      AllowUsers = ["max"];
      MaxAuthTries = 3;
      PerSourcePenalties = "crash:3600s authfail:3600s max:86400s";
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05"; # Did you read the comment?
}
