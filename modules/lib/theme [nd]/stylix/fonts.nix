{
  # The fonts every program uses. Programs import the `stylix` aspect and
  # either leave the fonts of their target enabled, or read
  # `config.stylix.fonts` in their own file.
  #
  # Only the values are set here, the `font` aspect installs the fonts.
  flake.modules.homeManager.stylix = {
    lib,
    pkgs,
    ...
  }: let
    lilex = name: {
      name = lib.mkDefault name;
      package = lib.mkDefault pkgs.nerd-fonts.lilex;
    };
  in {
    # Deduplicates the module, see `dotfiles-users` in `lib/users [N]/users.nix`
    key = "dotfiles-stylix-fonts";

    stylix.fonts = {
      serif = lilex "Lilex Nerd Font Propo";
      sansSerif = lilex "Lilex Nerd Font";
      monospace = lilex "Lilex Nerd Font Mono";

      # `terminal` follows `applications`, `popups` follows `desktop`
      sizes = {
        applications = lib.mkDefault 10;
        desktop = lib.mkDefault 10;
      };
    };
  };
}
