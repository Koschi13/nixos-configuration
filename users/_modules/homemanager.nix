{ ... }:

{
  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;

    gpg.enable = true;

    fzf = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };
  };
}
