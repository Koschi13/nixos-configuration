# TODO: it is not fully working, probably due to zsh-fzf-tab
{ zsh-enhancd, ... }:

{
  programs.zsh.plugins = [
    {
      name = "zsh-enhancd";
      file = "enhancd.plugin.zsh";
      src = "${zsh-enhancd}";
    }
  ];

  home.sessionVariables = {
    ENHANCD_FILTER="fzf --height 40%";
  };
}