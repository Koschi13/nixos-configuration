{self, ...}: {
  # Minecraft through PrismLauncher for all users of a host
  flake.modules.nixos.minecraft = {
    imports = [self.modules.nixos.gaming];

    home-manager.sharedModules = [self.modules.homeManager.minecraft];
  };

  flake.modules.homeManager.minecraft = {pkgs, ...}: {
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
  };
}
