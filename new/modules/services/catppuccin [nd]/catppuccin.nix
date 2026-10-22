{inputs, ...}: {
  # The Catppuccin Frappé theme. Every program opts in on its own, so nothing
  # gets themed by surprise when catppuccin/nix gains a new port.
  flake.modules.homeManager.catppuccin = {
    imports = [inputs.catppuccin.homeModules.catppuccin];

    catppuccin = {
      enable = true;
      autoEnable = false;
      flavor = "frappe";

      sway.enable = true;
      starship.enable = true;
      alacritty.enable = true;
      ghostty.enable = true;
    };
  };
}
