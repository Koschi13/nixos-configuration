{ pkgs, ... }:

{
  programs.zsh = {
    plugins = [{
      name = "forgit";
      file = "forgit.plugin.zsh";
      src = "${pkgs.zsh-forgit}/share/zsh/zsh-forgit";
    }];
    initExtraBeforeCompInit = ''
      # forgit alias, prefix all with f
      forgit_log=fglo
      forgit_diff=fgd
      forgit_add=fga
      forgit_reset_head=fgrh
      forgit_ignore=fgi
      forgit_checkout_file=fgcf
      forgit_checkout_branch=fgcb
      forgit_branch_delete=fgbd
      forgit_checkout_tag=fgct
      forgit_checkout_commit=fgco
      forgit_revert_commit=fgrc
      forgit_clean=fgclean
      forgit_stash_show=fgss
      forgit_stash_push=fgsp
      forgit_cherry_pick=fgcp
      forgit_rebase=fgrb
      forgit_blame=fgbl
      forgit_fixup=fgfu
    '';
  };
}
