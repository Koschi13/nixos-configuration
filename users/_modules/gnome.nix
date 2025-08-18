{pkgs, ...}: let
  unlockKeyring = pkgs.writeShellScriptBin "unlock-keyring" ''
    #!/usr/bin/env bash
    read -rsp "Password: " pass
    export $(echo -n "$pass" | gnome-keyring-daemon --replace --unlock)
    unset pass
  '';
in {
  # GNOME related packages
  home.packages = with pkgs; [
    eog
    gnome-tweaks
    nautilus
    networkmanagerapplet
    pinentry-gnome3
    seahorse
    unlockKeyring
  ];
}
