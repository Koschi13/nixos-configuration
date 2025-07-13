{...}: let
  settings = builtins.readFile ./settings.json;
  keybindings = builtins.readFile ./keybindings.json;
in {
  home.file.".config/VSCodium/User/settings.json".text = settings;
  home.file.".config/Code/User/settings.json".text = settings;
  home.file.".config/Code/User/keybindings.json".text = keybindings;
  home.file.".config/VSCodium/User/keybindings.json".text = settings;
}
