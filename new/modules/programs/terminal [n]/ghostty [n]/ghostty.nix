{
  # The theme comes from the catppuccin aspect
  flake.modules.homeManager.ghostty = {
    programs.ghostty = {
      enable = true;

      installVimSyntax = true;
      enableZshIntegration = true;

      settings = {
        copy-on-select = "clipboard";
        background-opacity = 0.85;
        background-blur = 16;

        mouse-hide-while-typing = true;

        working-directory = "home";
        # Prevents new terminals from being opened in the last opened directory
        gtk-single-instance = false;
        shell-integration-features = "ssh-env,ssh-terminfo";
      };
    };
  };
}
