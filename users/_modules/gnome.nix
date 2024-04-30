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
    gnome.gnome-tweaks
    gnome.seahorse
    gnome.nautilus
  ];
}
