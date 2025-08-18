{config, ...}: {
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";

    flake = "${config.home.homeDirectory}/.dotfiles";
    homeFlake = "${config.home.homeDirectory}/.dotfiles";
    osFlake = "${config.home.homeDirectory}/.dotfiles";
  };
}
