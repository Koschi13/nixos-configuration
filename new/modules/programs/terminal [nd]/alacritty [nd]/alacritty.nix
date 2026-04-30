{inputs, ...}: {
  flake.modules.homeManager.alacritty = {config, ...}: let
    catppuccin-frappe-toml = ".config/alacritty/catppuccin-frappe.toml";
  in {
    programs.alacritty = {
      enable = true;
      settings = {
        env.TERM = "xterm-256color";
        general.import = [
          "${config.home.homeDirectory}/${catppuccin-frappe-toml}"
        ];
      };
    };

    home.file."${catppuccin-frappe-toml}" = {
      source = inputs.catppuccinAlacritty + "/catppuccin-frappe.toml";
    };
  };
}
