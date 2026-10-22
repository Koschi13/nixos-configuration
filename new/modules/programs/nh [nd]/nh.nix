{
  flake.modules.homeManager.nh = {config, ...}: {
    # Garbage collection is done by the system, see `system-default`
    programs.nh = {
      enable = true;

      flake = "${config.home.homeDirectory}/.dotfiles/new"; # TODO: change to ${config.home.homeDirectory}/.dotfiles when new/ is promoted to repo root
    };
  };
}
