{ inputs, lib, config, pkgs, ... }: {

  # GNOME related packages
  home.packages = with pkgs; [
    pinentry-gnome
    gnome.gnome-tweaks
    gnome.seahorse
  ];
}
