{self, ...}: {
  flake.modules.homeManager.awww = {
    # scripts are required for wallpaper_random
    imports = with self.modules.homeManager; [scripts];

    services.awww.enable = true;
  };
}
