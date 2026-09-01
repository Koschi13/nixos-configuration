{catppuccinGhostty, ...}: let
  catppuccin-frappe-toml = ".config/ghostty/themes/catppuccin-frappe.conf";
in {
  programs.ghostty = {
    enable = true;

    installVimSyntax = true;
    enableZshIntegration = true;

    settings = {
      theme = "catppuccin-frappe.conf";
      # TODO: make this global for with rewrite
      font-size = 10;
      font-family = "Lilex Nerd Font Mono";

      copy-on-select = "clipboard";
      background-opacity = 0.85;
      background-blur = 16;

      mouse-hide-while-typing = true;

      working-directory = "home";
      # Prevents new terminals from being opened in the last opened directory
      gtk-single-instance = false;
    };
  };

  home.file."${catppuccin-frappe-toml}" = {
    source = catppuccinGhostty + "/themes/catppuccin-frappe.conf";
  };

  home.sessionVariables = {
    TERMINAL = "ghostty";
  };
}
