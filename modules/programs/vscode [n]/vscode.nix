{self, ...}: {
  # TODO: unify font settings in json files via font.nix
  flake.modules.homeManager.vscode = {config, ...}: let
    inherit (config.dotfiles.theme) active;
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

    # The file is JSONC, so it can't go through `builtins.fromJSON`. Every
    # variant writes its own file, so the active theme is the preferred one
    # of both system color schemes.
    settings =
      builtins.replaceStrings
      ["@colorTheme@" "@iconTheme@"]
      [(colorTheme active) iconTheme]
      (builtins.readFile ./settings.json);
    keybindings = builtins.readFile ./keybindings.json;
  in {
    imports = [self.modules.homeManager.dotfiles-theme];

    home.file.".config/VSCodium/User/settings.json".text = settings;
    home.file.".config/Code/User/settings.json".text = settings;
    home.file.".config/Code/User/keybindings.json".text = keybindings;
    home.file.".config/VSCodium/User/keybindings.json".text = keybindings;
  };
}
