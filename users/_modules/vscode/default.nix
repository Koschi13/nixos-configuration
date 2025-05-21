{...}: {
  home.file.".config/Code/User/settings.json".text = builtins.readFile ./settings.json;
}
