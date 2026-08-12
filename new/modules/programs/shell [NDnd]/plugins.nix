# The 'file' which is needed for each plugin entry must be looked up in the
# repository. Some are named as the plugin while others have different names.
# For the packages coming from the NIX store you need to look into the source
# and see which files are added to the build context (or look up the original
# repo)
#
# For more plugins go here -> https://github.com/unixorn/awesome-zsh-plugins
{inputs, ...}: {
  flake.modules.homeManager.shell = {
    pkgs,
    lib,
    ...
  }: {
    programs.zsh.plugins = [
      #
      # From nixpkgs
      #
      {
        name = "fast-syntax-highlighting";
        file = "fast-syntax-highlighting.plugin.zsh";
        src = "${pkgs.zsh-fast-syntax-highlighting}/share/zsh/plugins/fast-syntax-highlighting";
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
        src = "${pkgs.zsh-history-substring-search}/share/zsh-history-substring-search";
      }
      {
        name = "zsh-autosuggestions";
        file = "zsh-autosuggestions.zsh";
        src = "${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions";
      }
      {
        name = "zsh-bd";
        file = "bd.zsh";
        src = "${pkgs.zsh-bd}/share/zsh-bd";
      }
      {
        name = "zsh-calc";
        file = "calc.plugin.zsh";
        src = "${inputs.zsh-calc}";
      }
      {
        name = "zsh-alias-finder";
        file = "zsh-alias-finder.plugin.zsh";
        src = "${inputs.zsh-alias-finder}";
      }

      #
      # forgit
      #
      {
        name = "forgit";
        file = "forgit.plugin.zsh";
        src = "${pkgs.zsh-forgit}/share/zsh/zsh-forgit";
      }

      #
      # oh-my-zsh
      #
      {
        # This is needed since oh-my-zsh.git requires some functions from lib
        name = "oh-my-zsh.git.functions";
        file = "git.zsh";
        src = "${pkgs.oh-my-zsh}/share/oh-my-zsh/lib";
      }
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

      # TODO: it is not fully working, probably due to zsh-fzf-tab
      {
        name = "zsh-enhancd";
        file = "enhancd.plugin.zsh";
        src = "${inputs.zsh-enhancd}";
      }
    ];

    # forgit alias, prefix all with f
    programs.zsh.initContent = lib.mkOrder 550 ''
      # forgit alias, prefix all with f
      forgit_add=fga
      forgit_blame=fgbl
      forgit_branch_delete=fgbd
      forgit_checkout_branch=fgcb
      forgit_checkout_commit=fgco
      forgit_checkout_file=fgcf
      forgit_checkout_tag=fgct
      forgit_cherry_pick=fgcp
      forgit_clean=fgclean
      forgit_diff=fgd
      forgit_fixup=fgfu
      forgit_switch_branch=fgsw
      forgit_ignore=fgi
      forgit_log=fglo
      forgit_rebase=fgrb
      forgit_reset_head=fgrh
      forgit_revert_commit=fgrc
      forgit_stash_push=fgsp
      forgit_stash_show=fgss
    '';

    # enhancd
    home.sessionVariables = {
      ENHANCD_FILTER = "fzf --height 40%";
    };
  };
}
