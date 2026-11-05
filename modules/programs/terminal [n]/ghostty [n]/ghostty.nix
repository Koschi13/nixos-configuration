{self, ...}: {
  flake.modules.homeManager.ghostty = {
    imports = [self.modules.homeManager.stylix];

    stylix.targets.ghostty = {
      enable = true;
      # The font comes from `font.nix`, the opacity is set below
      fonts.enable = false;
      opacity.enable = false;
    };

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
