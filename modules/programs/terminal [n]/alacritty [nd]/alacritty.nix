{self, ...}: {
  flake.modules.homeManager.alacritty = {
    imports = [self.modules.homeManager.stylix];

    stylix.targets.alacritty = {
      enable = true;
      opacity.enable = false;
    };

    programs.alacritty = {
      enable = true;
      settings = {
        env.TERM = "xterm-256color";
        # Spreads the leftover pixels of the window evenly around the grid
        window.dynamic_padding = true;
      };
    };
  };
}
