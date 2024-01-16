{ config, pkgs, ... }:

{
  home.sessionVariables = {
    XDG_CURRENT_DESKTOP = "sway";
    XDG_SESSION_DESKTOP = "sway";
    XDG_SESSION_TYPE = "wayland";

    # grim screenshot location
    GRIM_DEFAULT_DIR = "$HOME/Pictures/Screenshots/";
  };
}
