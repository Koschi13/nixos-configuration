{ inputs, lib, config, pkgs, ... }: {

  # GNOME
  home.packages = with pkgs; [
    gnome.gnome-tweaks
  ];
}
