{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
{

  # GNOME related packages
  home.packages = with pkgs; [
    pinentry-gnome3
    gnome-tweaks
    seahorse
    nautilus
  ];
}
