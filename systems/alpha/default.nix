{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan
    ./hardware-configuration.nix
    ../default.nix
  ];

  networking = {
    hostName = "alpha";
  };

  services = {
    displayManager = {
      defaultSession = "xfce+i3";
    };

    xserver = {
      windowManager.i3.enable = true;


      desktopManager = {
        xterm.enable = false;
        xfce = {
          enable = true;
          noDesktop = true;
          enableXfwm = false;
          enableScreensaver = false;
        };
      };

      videoDrivers = [ "nvidia" ];
    };
  };

  environment.xfce.excludePackages = (
    with pkgs.xfce;
    [
      thunar
      exo
      mousepad
      parole
      ristretto
      xfce4-power-manager
      xfce4-taskmanager
      xfce4-screenshooter
      xfce4-screensaver
      xfce4-terminal
      xfce4-appfinder
      xfce4-panel
    ]
  );

  environment.systemPackages = (with pkgs; [ xfce.xfce4-settings ]);

  programs.thunar.enable = lib.mkForce false;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05"; # Did you read the comment?
}
