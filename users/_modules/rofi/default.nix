{ config, pkgs, ... }:
let
  rofiWindow = pkgs.writeShellScriptBin "rofiWindow" ''
    #!/usr/bin/env bash
    ## Run
    rofi \
      -show drun \
      -theme "$HOME/.config/rofi/theme.rasi"
  '';
  catppuccin-filename = "colors/catppuccin.rasi";
in {
  home.packages = with pkgs; [ rofiWindow ];

  programs.rofi = {
    enable = true;
    terminal = "${pkgs.alacritty}/bin/alacritty";
    theme = ./theme.rasi;
  };

  home.file = {
    ".config/rofi/theme.rasi".text = ''
      @import "./${catppuccin-filename}"
    '' + (builtins.readFile ./theme.rasi);
    ".config/rofi/${catppuccin-filename}".text =
      (builtins.readFile ./${catppuccin-filename});
  };
}
