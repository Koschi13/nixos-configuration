{self, ...}: {
  flake.modules.homeManager.awww = {
    # scripts are required for random_wallpaper.sh
    imports = with self.modules.homeManager; [scripts];

    services.awww.enable = true;
  };
}
