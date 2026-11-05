{self, ...}: {
  # Switches between the variants of `dotfiles.theme` at runtime, through
  # `theme <variant>|toggle|status|list`.
  #
  # Every rebuild builds all variants, each one but the default as
  # Home-Manager specialisation, so switching only runs an already built
  # activation. The chosen variant is kept in `~/.local/state/dotfiles/theme`
  # and restored after every activation of the base generation, e.g. by a
  # rebuild or a login.
  flake.modules.homeManager.theme-switch = {
    config,
    lib,
    pkgs,
    ...
  }: let
    themeConfig = config.dotfiles.theme;
    theme = pkgs.writers.writePython3Bin "theme" {} (builtins.readFile ./theme.py);
  in {
    imports = [self.modules.homeManager.dotfiles-theme];

    specialisation = lib.mapAttrs (variant: _: {
      configuration.dotfiles.theme.variant = variant;
    }) (removeAttrs themeConfig.variants [themeConfig.default]);

    home.packages = [theme];

    # Names the variant of each generation, so `theme` knows the default one
    # (the base generation) without a list of its own
    home.extraBuilderCommands = ''
      echo ${lib.escapeShellArg themeConfig.variant} >$out/theme-variant
    '';

    # The portal publishes it to the applications following the system color
    # scheme, like Firefox, GTK apps, VSCode and Zed
    dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-${themeConfig.active.polarity}";

    # Links the base generation for `theme` and restores the chosen variant
    home.activation.dotfilesTheme = lib.hm.dag.entryAfter ["writeBoundary"] (
      builtins.replaceStrings ["@systemdRun@" "@theme@"] [
        "${pkgs.systemd}/bin/systemd-run"
        "${theme}/bin/theme"
      ] (builtins.readFile ./activation.sh)
    );
  };
}
