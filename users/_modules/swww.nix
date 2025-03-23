{pkgs, ...}: let
  wallpaper_random = pkgs.writeShellScriptBin "wallpaper_random" ''
    if command -v swww >/dev/null 2>&1; then
      swww img $(find ~/Pictures/Wallpapers/. -name "*.png" -o -name "*.jpg" | shuf -n1) --transition-type simple
    fi
  '';
  default_wallpaper = pkgs.writeShellScriptBin "default_wallpaper" ''
    if command -v swww >/dev/null 2>&1; then
      swww img ~/Pictures/Wallpapers/STScI-01G7ETPF7DVBJAC42JR5N6EQRH.png --transition-type simple
    fi
  '';
in {
  home.packages = with pkgs; [
    swww
    wallpaper_random
    default_wallpaper
  ];
}
