{pkgs, ...}: let
  wallpaper_random = pkgs.writeShellScriptBin "wallpaper_random" (builtins.readFile ./random_wallpaper.sh);
  compute_aspect_ratio = import ./compute_aspect_ratio/default.nix {inherit pkgs;};
in {
  home.packages = [
    compute_aspect_ratio
    wallpaper_random
  ];

  services.swww.enable = true;
}
