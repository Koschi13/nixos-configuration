let
  serif = "Lilex Nerd Font Propo";
  sansSerif = "Lilex Nerd Font";
  monospace = "Lilex Nerd Font Mono";
  fontSize = 10;
in {
  flake.modules.homeManager = {
    font = {pkgs, ...}: {
      home.packages = [pkgs.nerd-fonts.lilex];
      fonts.fontconfig = {
        enable = true;
        defaultFonts = {
          serif = [serif];
          sansSerif = [sansSerif];
          monospace = [monospace];
        };
      };
    };

    ghostty = {
      programs.ghostty.settings = {
        font-size = fontSize;
        font-family = monospace;
      };
    };

    alacritty = {
      programs.alacritty.settings.font = {
        normal.family = monospace;
        size = fontSize;
      };
    };

    dunst = {
      services.dunst.settings.global.font = "${monospace} ${toString fontSize}";
    };
  };
}
