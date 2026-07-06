{
  config,
  catppuccinAlacritty,
  ...
}: let
  catppuccin-frappe-toml = ".config/alacritty/catppuccin-frappe.toml";
in {
  programs.alacritty = {
    enable = true;
    settings = {
      env.TERM = "xterm-256color";
      font = {
        normal = {
          family = "Lilex Nerd Font Mono";
        };
        size = 10;
      };
      general.import = [
        "${config.home.homeDirectory}/${catppuccin-frappe-toml}"
      ];
    };
  };

  home.file."${catppuccin-frappe-toml}" = {
    source = catppuccinAlacritty + "/catppuccin-frappe.toml";
  };

  # home.sessionVariables = {
  #   TERMINAL = "alacritty";
  # };
}
