{self, ...}: {
  flake.modules.homeManager.alacritty = {
    imports = [self.modules.homeManager.stylix];

    stylix.targets.alacritty = {
      enable = true;
      # The font comes from `font.nix`
      fonts.enable = false;
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
