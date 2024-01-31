# TODO: For more go here -> https://github.com/unixorn/awesome-zsh-plugins
{ pkgs, zsh-calc, zsh-alias-finder, ... }:

{
  imports = [ ./enhancd.nix ./forgit.nix ./oh-my-zsh/default.nix ];

  programs.zsh.plugins = [
    {
      name = "fast-syntax-highlighting";
      file = "fast-syntax-highlighting.plugin.zsh";
      src = "${pkgs.zsh-fast-syntax-highlighting}/share/zsh/site-functions";
    }
    {
      name = "zsh-fzf-tab";
      file = "fzf-tab.plugin.zsh";
      src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
    }
    {
      name = "zsh-completions";
      file = "zsh-completions.zsh";
      src = "${pkgs.zsh-completions}/share/zsh/site-functions";
    }
    {
      name = "nix-zsh-completions";
      file = "nix-zsh-completions.plugin.zsh";
      src = "${pkgs.nix-zsh-completions}/share/zsh/plugins/nix";
    }
    {
      name = "zsh-history-substring-search";
      file = "zsh-history-substring-search.zsh";
      src =
        "${pkgs.zsh-history-substring-search}/share/zsh-history-substring-search";
    }
    {
      name = "zsh-autosuggestions";
      file = "zsh-autosuggestions.zsh";
      src = "${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions";
    }
    {
      name = "zsh-bd";
      file = "zsh-bd.zsh";
      src = "${pkgs.zsh-bd}/share/zsh-bd";
    }
    {
      name = "zsh-calc";
      file = "calc.plugin.zsh";
      src = "${zsh-calc}";
    }
    {
      name = "zsh-alias-finder";
      file = "zsh-alias-finder.plugin.zsh";
      src = "${zsh-alias-finder}";
    }
  ];
}
