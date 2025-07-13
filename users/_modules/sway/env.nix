{...}: {
  home.sessionVariables = {
    XDG_CURRENT_DESKTOP = "sway";
    XDG_SESSION_DESKTOP = "sway";
    XDG_SESSION_TYPE = "wayland";

    # Enable wayland in electron based apps
    NIXOS_OZONE_WL = "1";

    # grim screenshot location
    GRIM_DEFAULT_DIR = "$HOME/Pictures/Screenshots/";
  };
}
