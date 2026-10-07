{pkgs, ...}: let
in {
  home = {
    packages = with pkgs; [
      # Cursor theme to fix crashes
      adwaita-icon-theme

      # Launcher
      prismlauncher
      libx11
      libGL
      glfw3-minecraft
    ];

    sessionVariables = {
      XCURSOR_THEME = "Adwaita";
    };

    file = {
      ".icons/default/index.theme".text = ''
        [Icon Theme]
        Inherits=Adwaita
      '';
    };
  };
}
