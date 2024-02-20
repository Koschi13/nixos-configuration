{ inputs, lib, config, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan
    ./hardware-configuration.nix
    ../default.nix
  ];

  networking = { hostName = "epsilon"; };

  programs.light.enable = true;
  xdg = {
    portal = {
      wlr.enable = true;

      extraPortals = with pkgs;
        [
          # Enable the hyprland portal (if using hyprland)
          # xdg-desktop-portal-hyprland
        ];
    };
  };

  programs.regreet.enable = true;
  services.greetd = {
    enable = true;
    settings = {
      initial_session = {
        user = "max";
        command = "$SHELL -l";
      };
    };
  };

  services.logind.extraConfig = ''
    RuntimeDirectorySize=6G
  '';

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05"; # Did you read the comment?
}
