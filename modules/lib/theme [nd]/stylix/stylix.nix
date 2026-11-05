{
  inputs,
  self,
  ...
}: {
  # Themes programs with the scheme of the active theme, for any theme family.
  # Programs import this aspect and enable their target on their own:
  #
  # ```nix
  # stylix.targets.sway.enable = true;
  # ```
  flake.modules.homeManager.stylix = {config, ...}: let
    theme = config.dotfiles.theme.active;
  in {
    # Deduplicates the module, see `dotfiles-users` in `lib/users [N]/users.nix`
    key = "dotfiles-stylix";

    imports = [
      inputs.stylix.homeModules.stylix
      self.modules.homeManager.dotfiles-theme
    ];

    stylix = {
      enable = true;
      # No target is enabled by default, so nothing gets themed by surprise
      # when stylix gains a new one
      autoEnable = false;
      base16Scheme = theme.scheme;
      inherit (theme) polarity;
    };
  };
}
