{
  flake.modules.homeManager.nh = {config, ...}: {
    programs.nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 4d --keep 3";

      flake = "${config.home.homeDirectory}/.dotfiles/new"; # TODO: change to ${config.home.homeDirectory}/.dotfiles when new/ is promoted to repo root
    };
  };
}
