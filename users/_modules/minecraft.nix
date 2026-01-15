{pkgs, ...}:
{
  home = {
    packages = with pkgs; [
      # Cursor theme to fix crashes
      adwaita-icon-theme
      
      # Launcher
      prismlauncher
  ];


    sessionVariables = {
      XCURSOR_THEME="Adwaita";
    };

    file = {
      ".icons/default/index.theme".text = ''
        [Icon Theme]
        Inherits=Adwaita
      '';
    };
  };
}
