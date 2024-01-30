{ inputs, lib, config, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan
    ./hardware-configuration.nix
    ../default.nix
  ];

  networking = {
    hostName = "epsilon";
  };

  programs.light.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05"; # Did you read the comment?
}
