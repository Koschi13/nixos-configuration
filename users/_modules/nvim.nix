{ astro-nvim-config, pkgs, ... }:

{
  home = {
    sessionVariables = {
      VISUAL = "nvim";
      EDITOR = "nvim";
    };

    packages = with pkgs; [
      gcc
      gnumake

      # TODO: enable once the astrolsp file was removed from my fork
      #       then write the file using nix as described here:
      #       https://docs.astronvim.com/recipes/advanced_lsp/#lsp-setup-without-installer
      #
      # LSPs
      # pyright
    ];

    file = {
      "./.config/nvim/" = {
        source = astro-nvim-config;
        recursive = true;
      };
    };
  };
}
