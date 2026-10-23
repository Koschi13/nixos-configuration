{self, ...}: {
  flake.modules.homeManager.rofi = let
    catppuccin-filename = "colors/catppuccin.rasi";
  in {
    # provides rofiWindow
    imports = with self.modules.homeManager; [scripts];

    programs.rofi = {
      enable = true;
      theme = ./theme.rasi;
      # terminal is configured by the terminal aspect
    };

    home.file = {
      ".config/rofi/theme.rasi".text =
        ''
          @import "./${catppuccin-filename}"
        ''
        + (builtins.readFile ./theme.rasi);
      ".config/rofi/${catppuccin-filename}".text = builtins.readFile ./${catppuccin-filename};
    };
  };
}
