{self, ...}: {
  flake.modules.homeManager.ghostty = {
    imports = [self.modules.homeManager.stylix];

    stylix.targets.ghostty = {
      enable = true;
      # The opacity is set below
      opacity.enable = false;
    };

    programs.ghostty = {
      enable = true;

      installVimSyntax = true;
      enableZshIntegration = true;

      settings = {
        copy-on-select = "clipboard";
        background-opacity = 0.85;
        background-blur = 16;

        # The window is rarely a multiple of the cell size. Spreads the
        # leftover pixels around the grid and fills them with the color of the
        # nearest cells, instead of an empty transparent bar at the bottom.
        window-padding-balance = true;
        window-padding-color = "extend";

        mouse-hide-while-typing = true;

        working-directory = "home";
        # Prevents new terminals from being opened in the last opened directory
        gtk-single-instance = false;
        shell-integration-features = "ssh-env,ssh-terminfo";
      };
    };
  };
}
