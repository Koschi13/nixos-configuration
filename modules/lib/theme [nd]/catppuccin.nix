{inputs, ...}: {
  # https://catppuccin.com, as base24 schemes of `tinted-schemes`
  flake.themes = {
    catppuccin-frappe = {
      scheme = "${inputs.tinted-schemes}/base24/catppuccin-frappe.yaml";
      polarity = "dark";
      integrations = {
        nvim = "catppuccin-frappe";
        vscode = "Catppuccin Frappé";
        vscodeIcons = "catppuccin-frappe";
      };
    };

    catppuccin-latte = {
      scheme = "${inputs.tinted-schemes}/base24/catppuccin-latte.yaml";
      polarity = "light";
      integrations = {
        nvim = "catppuccin-latte";
        vscode = "Catppuccin Latte";
        vscodeIcons = "catppuccin-latte";
      };
    };
  };
}
