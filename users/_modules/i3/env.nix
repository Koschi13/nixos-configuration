{ config, pkgs, ... }:

{
  home.sessionVariables = {
    XDG_CURRENT_DESKTOP = "i3";
    XDG_SESSION_DESKTOP = "i3";
    XDG_SESSION_TYPE = "x11";
  };
}
