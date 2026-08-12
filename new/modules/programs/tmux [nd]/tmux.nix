{
  flake.modules.homeManager.tmux = {pkgs, ...}: {
    programs.tmux = {
      enable = true;
      keyMode = "vi";
      # TODO: link with shell? Is there a way to get the info about the default shell?
      shell = "${pkgs.zsh}/bin/zsh";
    };
  };
}
