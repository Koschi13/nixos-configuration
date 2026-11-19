{self, ...}: {
  # Installs the fonts of `stylix.fonts` and makes them the default ones. The
  # values are set in `lib/theme [nd]/stylix/fonts.nix`.
  flake.modules.homeManager.font = {
    imports = [self.modules.homeManager.stylix];

    fonts.fontconfig.enable = true;

    stylix.targets = {
      fontconfig.enable = true;
      font-packages.enable = true;
    };
  };
}
