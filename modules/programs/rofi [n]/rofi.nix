{self, ...}: {
  flake.modules.homeManager.rofi = {config, ...}: let
    # The stylix target replaces the whole theme, so only the
    # colors are taken from stylix and `theme.rasi` keeps the layout
    colors = with config.lib.stylix.colors; ''
      * {
          background:     #${base00};
          background-alt: #${base04};
          foreground:     #${base05};
          selected:       #${base0D};
          active:         #${base0A};
          urgent:         #${base08};
      }
    '';
  in {
    imports = with self.modules.homeManager; [
      # provides rofiWindow
      scripts
      stylix
    ];

    programs.rofi = {
      enable = true;
      theme = ./theme.rasi;
      # terminal is configured by the terminal aspect
    };

    home.file = {
      ".config/rofi/theme.rasi".text =
        ''
          @import "./colors.rasi"
        ''
        + (builtins.readFile ./theme.rasi);
      ".config/rofi/colors.rasi".text = colors;
    };
  };
}
