# Fonts as a pulled shared option

## Why

`modules/services/font [nd]/font.nix` is a cross-cutting module: it holds the font
values *and* pushes them into other aspects (`homeManager.ghostty`, `alacritty`,
`dunst`). This turned out to be a bad trade-off:

- Adding a program means remembering to also edit `font.nix`.
- Removing a program leaves a silent leftover: `font.nix` still defines e.g.
  `homeManager.dunst` with only font settings, and nothing fails.
- A program file doesn't show which font settings apply to it.

The theme (see `dotfiles.theme` in `modules/lib/theme [nd]/`) already uses the
replacement pattern. Fonts should follow it for consistency.

## First: check `stylix.fonts`

The theme now uses [stylix](https://github.com/nix-community/stylix)
(`modules/lib/theme [nd]/stylix/`), and stylix themes fonts as well. Every
program enabling a stylix target currently turns the fonts off
(`stylix.targets.<program>.fonts.enable = false;`), and `sway.nix` forces
`wayland.windowManager.sway.config.fonts = lib.mkForce {};`, because the
sway target sets the fonts without a toggle.

Before building an own `dotfiles.font` option, check whether `stylix.fonts`
(`serif`, `sansSerif`, `monospace`, `sizes.*`) can replace `font.nix`. It
follows the same rule as the theme: external projects first, own code only
for what they don't cover. If it fits:

1. Set `stylix.fonts` in the `stylix` aspect (`lib/theme [nd]/stylix/stylix.nix`,
   or a separate aspect if fonts shouldn't depend on the theme) with the
   current values of `font.nix`, and enable the `fontconfig` and
   `font-packages` targets there.
2. Remove `fonts.enable = false;` from the stylix targets and the sway
   `mkForce`.
3. Programs without a stylix target (vscode, neovim, waybar's own CSS) read
   `config.stylix.fonts` in their own file.
4. Delete `font.nix`.

Only if stylix doesn't fit, follow the steps below.

## Target pattern

Values are a Home-Manager shared option, applied in each program's own file,
which imports the option module explicitly:

```nix
flake.modules.homeManager.dunst = {config, ...}: let
  font = config.dotfiles.font;
in {
  imports = [self.modules.homeManager.dotfiles-font];
  services.dunst.settings.global.font = "${font.monospace} ${toString font.size}";
};
```

- Don't import `dotfiles-font` in `system-default`: a program reading
  `config.dotfiles.font` without importing it then fails evaluation, and each
  program aspect stays importable on its own.
- An option (instead of a `let` constant) keeps it consistent with
  `dotfiles.theme` and lets a host override it through
  `home-manager.users.<user>.dotfiles.font.size`.

## Steps

1. Create `modules/lib/font [nd]/font.nix` defining
   `flake.modules.homeManager.dotfiles-font` with `key = "dotfiles-font";`
   (dedup, see `modules/lib/users [N]/users.nix`) and options
   `dotfiles.font.{serif,sansSerif,monospace,size}`. Defaults: the current values
   of `font.nix` (`Lilex Nerd Font Propo`, `Lilex Nerd Font`,
   `Lilex Nerd Font Mono`, `10`). Mirror the structure of
   `modules/lib/theme [nd]/theme.nix`.
2. Keep a `homeManager.font` aspect (package `nerd-fonts.lilex` + `fontconfig`
   defaults), reading the option, imported by `system-desktop` as today.
3. Move the font settings into `ghostty.nix`, `alacritty.nix`, `dunst.nix`,
   each importing `dotfiles-font`. Delete the old push blocks and the old
   `services/font [nd]` directory.
4. Resolve the existing font TODOs the same way:
   - `programs/vscode [n]`: `editor.fontFamily` and the various `*.fontSize`
     (currently `13`) in `settings.json` via `builtins.replaceStrings`
     placeholders (the file is JSONC, `fromJSON` fails), like the theme
     placeholders there.
   - `programs/neovim [Nn]`: generate a small lua file with the font, like
     `dotfiles_theme.lua`.
   - `programs/waybar [n]`: `font-family` / `font-size` in `style.css` via the
     generated header, like the `@define-color` block.
   Decide whether vscode's size 13 should stay an explicit per-program
   override or derive from `dotfiles.font.size`.
5. README: in "Shared options", add `dotfiles.font`. Rewrite "Cross-cutting
   features": values (fonts, colors) are shared options pulled by each program;
   cross-cutting files are only for choosing *which* program fills a role
   (`terminal.nix` stays as is).

## Verification

- `nh os build .#` for every host; `nvd diff` against the current system shows
  only the vscode/neovim/waybar files changing (font values themselves must be
  identical).
- `grep -rn "Lilex" modules` only hits `lib/font [nd]`.
