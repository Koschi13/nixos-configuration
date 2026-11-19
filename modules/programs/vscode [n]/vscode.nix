{self, ...}: {
  flake.modules.homeManager.vscode = {config, ...}: let
    inherit (config.dotfiles.theme) active;
    inherit (config.stylix) fonts;
    # Themes without a VSCode theme fall back to the builtin ones
    colorTheme = theme:
      if theme.integrations.vscode != null
      then theme.integrations.vscode
      else if theme.polarity == "dark"
      then "Default Dark Modern"
      else "Default Light Modern";
    iconTheme =
      if active.integrations.vscodeIcons != null
      then active.integrations.vscodeIcons
      else "vs-seti";

    # VSCode sizes fonts in pixels, `stylix.fonts.sizes` are points
    fontSize = builtins.floor (fonts.sizes.terminal * 4.0 / 3.0 + 0.5);

    # The file is JSONC, so it can't go through `builtins.fromJSON`. Every
    # variant writes its own file, so the active theme is the preferred one
    # of both system color schemes.
    settings =
      builtins.replaceStrings
      ["@colorTheme@" "@iconTheme@" "@fontFamily@" "\"@fontSize@\""]
      [(colorTheme active) iconTheme fonts.monospace.name (toString fontSize)]
      (builtins.readFile ./settings.json);
    keybindings = builtins.readFile ./keybindings.json;
  in {
    imports = with self.modules.homeManager; [dotfiles-theme stylix];

    home.file.".config/VSCodium/User/settings.json".text = settings;
    home.file.".config/Code/User/settings.json".text = settings;
    home.file.".config/Code/User/keybindings.json".text = keybindings;
    home.file.".config/VSCodium/User/keybindings.json".text = keybindings;
  };
}
