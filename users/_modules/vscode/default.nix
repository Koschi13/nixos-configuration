{...}: {
  home.file.".config/Code/User/settings.json".text = builtins.readFile ./settings.json;
  home.file.".config/Code/User/keybindings.json".text = builtins.readFile ./keybindings.json;
}
