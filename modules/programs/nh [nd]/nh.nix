{
  flake.modules.homeManager.nh = {config, ...}: {
    # Garbage collection is done by the system, see `system-default`
    programs.nh = {
      enable = true;

      flake = "${config.home.homeDirectory}/.dotfiles";
    };
  };
}
