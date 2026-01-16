{
  pkgs,
  lib,
  ...
}: {
  programs.zsh = {
    plugins = [
      {
        name = "forgit";
        file = "forgit.plugin.zsh";
        src = "${pkgs.zsh-forgit}/share/zsh/zsh-forgit";
      }
    ];
    initContent = lib.mkOrder 550 ''
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
  };
}
