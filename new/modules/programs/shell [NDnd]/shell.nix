{
  flake.modules = {
    nixos.shell = {
      programs.bash.enable = true;

      environment.pathsToLink = [
        "/share/zsh"
      ];
    };
    darwin.shell = {
      programs.bash.enable = true;

      environment.pathsToLink = [
        "/share/zsh"
      ];
    };
    homeManager.shell = {
      # TODO
    };
  };
}
