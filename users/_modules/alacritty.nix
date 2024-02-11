{ ... }:

let catppuccin-frappe-toml = ".config/alacritty/catppuccin-frappe.toml";
in {
  programs.alacritty = {
    enable = true;
    settings = {
      env.TERM = "xterm-256color";
      font = {
        normal = {
          family = "DejaVuSansMono";
        };
        size = 10;
      };
      import = [
        # TODO: instead of ~ use home variable
        "~/${catppuccin-frappe-toml}"
      ];
    };
  };
  home.file."${catppuccin-frappe-toml}" = {
    # TODO: utilize flake and let it decide the hash
    source = builtins.fetchurl {
      url =
        "https://raw.githubusercontent.com/catppuccin/alacritty/main/catppuccin-frappe.toml";
      sha256 =
        "461af95c4c5a634605dadf8f570c414485d0e7c4c7d7e90cb9eef090a35a4892";
    };
  };
}
