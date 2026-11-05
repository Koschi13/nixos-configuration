{self, ...}: {
  flake.modules.homeManager.zed = {pkgs, ...}: {
    imports = [self.modules.homeManager.stylix];

    # The settings stay mutable, so everything but the theme is still
    # configured in zed itself
    stylix.targets.zed = {
      enable = true;
      # The font is configured in zed itself
      fonts.enable = false;
    };

    programs.zed-editor = {
      enable = true;
      # Required by the agent sandbox
      extraPackages = with pkgs; [bubblewrap];
    };
  };
}
