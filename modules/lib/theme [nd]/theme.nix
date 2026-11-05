{
  self,
  lib,
  ...
}: let
  themeType = lib.types.submodule {
    options = {
      scheme = lib.mkOption {
        type = lib.types.path;
        example = lib.literalExpression ''"''${inputs.tinted-schemes}/base24/gruvbox-dark.yaml"'';
        description = ''
          The base24 (or base16) scheme of the theme, the palette stylix
          themes the programs with.
        '';
      };

      polarity = lib.mkOption {
        type = lib.types.enum ["dark" "light"];
        description = "Whether the theme has a dark or a light background.";
      };

      integrations = lib.genAttrs ["nvim" "vscode" "vscodeIcons"] (name:
        lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Name of the theme in `${name}`, for programs shipping the theme themselves.";
        });
    };
  };
in {
  # The available themes. A theme is a base24 (or base16) scheme of
  # https://github.com/tinted-theming/schemes (the `tinted-schemes` input),
  # so any theme family can be added with one file, see `catppuccin.nix`.
  options.flake.themes = lib.mkOption {
    type = lib.types.lazyAttrsOf themeType;
    default = {};
    description = "The themes `dotfiles.theme` can choose from.";
  };

  # Declares which theme is active. Programs are themed through the `stylix`
  # aspect, which reads it. Programs read it themselves only for what stylix
  # doesn't cover, e.g. `dotfiles.theme.active.integrations.nvim`.
  #
  # `variant` is switched at runtime by the `theme-switch` aspect.
  config.flake.modules.homeManager.dotfiles-theme = {config, ...}: let
    themeConfig = config.dotfiles.theme;
    themeName = lib.types.enum (lib.attrNames self.themes);
  in {
    # Deduplicates the module, see `dotfiles-users` in `lib/users [N]/users.nix`
    key = "dotfiles-theme";

    options.dotfiles.theme = {
      variants = lib.mkOption {
        type = lib.types.attrsOf themeName;
        default = {
          dark = "catppuccin-frappe";
          light = "catppuccin-latte";
        };
        example = {dim = "gruvbox-dark";};
        description = ''
          The variants `theme` switches between, by name. Each one uses a
          theme of `flake.themes`, of any polarity.
        '';
      };

      default = lib.mkOption {
        type = lib.types.enum (lib.attrNames themeConfig.variants);
        default = "dark";
        description = "The variant of the base generation, used until switched.";
      };

      variant = lib.mkOption {
        type = lib.types.enum (lib.attrNames themeConfig.variants);
        default = themeConfig.default;
        defaultText = lib.literalExpression "config.dotfiles.theme.default";
        description = "The active variant. Don't set it, `theme-switch` does.";
      };

      active = lib.mkOption {
        type = lib.types.raw;
        readOnly = true;
        description = "The theme of the active variant.";
      };
    };

    config.dotfiles.theme.active = self.themes.${themeConfig.variants.${themeConfig.variant}};
  };
}
