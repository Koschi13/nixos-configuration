{
  flake.modules.homeManager.delta = {
    programs.delta = {
      enable = true;
      enableGitIntegration = true;
    };
  };
}
