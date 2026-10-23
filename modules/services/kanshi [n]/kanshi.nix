{
  # Hosts add their output layouts through `services.kanshi.settings`
  flake.modules.homeManager.kanshi = {
    services.kanshi.enable = true;
  };
}
