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
      };
    };
  };
}
