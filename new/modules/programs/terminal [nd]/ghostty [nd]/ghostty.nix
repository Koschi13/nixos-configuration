{inputs, ...}: {
  flake.modules.homeManager.ghostty = let
    catppuccin-frappe-toml = ".config/ghostty/themes/catppuccin-frappe.conf";
  in {
    programs.ghostty = {
      enable = true;

      installVimSyntax = true;
      enableZshIntegration = true;

      settings = {
        theme = "catppuccin-frappe.conf";

        copy-on-select = "clipboard";
        background-opacity = 0.85;
        background-blur = 16;

        mouse-hide-while-typing = true;

        working-directory = "home";
      };
    };

    home.file."${catppuccin-frappe-toml}" = {
      source = inputs.catppuccinGhostty + "/themes/catppuccin-frappe.conf";
    };
  };
}
