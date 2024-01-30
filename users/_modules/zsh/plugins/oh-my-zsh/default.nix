{ pkgs, ... }:

{
  programs.zsh.plugins = [
    {
      name = "oh-my-zsh.vi-mode";
      file = "vi-mode.plugin.zsh";
      src = "${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/vi-mode";
    }
    {
      name = "oh-my-zsh.git";
      file = "git.plugin.zsh";
      src = "${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/git";
    }
    {
      # This is needed since oh-my-zsh.git requires some functions from lib
      name = "oh-my-zsh.git.functions";
      file = "git.zsh";
      src = "${pkgs.oh-my-zsh}/share/oh-my-zsh/lib";
    }
    {
      # TODO: still not colored...
      name = "oh-my-zsh.colored-man-pages";
      file = "colored-man-pages.plugin.zsh";
      src = "${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/colored-man-pages";
    }
    {
      name = "oh-my-zsh.kubectl";
      file = "kubectl.plugin.zsh";
      src = "${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/kubectl";
    }
    {
      # TODO: read https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/aws
      name = "oh-my-zsh.aws";
      file = "aws.plugin.zsh";
      src = "${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/aws";
    }
    {
      name = "oh-my-zsh.extract";
      file = "extract.plugin.zsh";
      src = "${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/extract";
    }
    {
      name = "oh-my-zsh.rust";
      file = "rust.plugin.zsh";
      src = "${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/rust";
    }
    {
      name = "oh-my-zsh.sudo";
      file = "sudo.plugin.zsh";
      src = "${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/sudo";
    }
  ];
}
