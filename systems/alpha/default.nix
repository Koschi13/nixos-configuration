{pkgs, ...}: {
  imports = [
    ../default.nix
    ./cache.nix
    # Include the results of the hardware scan
    ./hardware-configuration.nix
    ./mounts.nix
    ./ollama.nix
    ./radeon.nix
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

  programs.regreet.enable = true;
  services.greetd = {
    enable = true;
    settings = {
      initial_session = {
        user = "max";
        command = "${pkgs.sway}/bin/sway --unsupported-gpu";
      };
    };
  };

  services.logind.extraConfig = ''
    RuntimeDirectorySize=6G
  '';

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05"; # Did you read the comment?
}
