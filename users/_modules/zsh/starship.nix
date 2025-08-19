{
  lib,
  pkgs,
  catppuccinStarship,
  ...
}:
with lib;
with builtins; let
  isRustFile = path: type: hasSuffix ".rs" path && type == "regular" && path != "mod.rs";
  mergeAllAttrSets = attrsSets: foldl' recursiveUpdate {} attrsSets;
  disableModules = isDisabled: modules: mergeAllAttrSets (map (mod: {"${mod}".disabled = isDisabled;}) modules);

  starshipPackage = pkgs.starship;
  promptOrder = [
    "directory"
    "git_branch"
    "git_commit"
    "git_state"
    "git_metrics"
    "git_status"
    "aws"
    "kubernetes"
    "line_break"
    "sudo"
    "nix_shell"
    "rust"
    "character"
  ];
  promptFormat = concatStrings (map (s: "\$${s}") promptOrder);
  modulesSources = readDir "${starshipPackage.src}/src/modules";
  enabledModules = disableModules false promptOrder; # <== enabled all modules used in the prompt are enabled
  disabledModules = pipe modulesSources [
    # <== from starship's sources...
    (filterAttrs isRustFile) # <== keep only Rust files...
    attrNames # <== get the filenames...
    (map (removeSuffix ".rs")) # <== remove Rust source extension...
    (subtractLists promptOrder) # <== do not disable modules used in the prompt...
    (disableModules true) # <== and finally build the configuration
  ];
  paletteSet = builtins.fromTOML (
    builtins.readFile (
      catppuccinStarship + "/themes/frappe.toml"
    )
  );
in {
  programs.starship = {
    package = starshipPackage;
    enable = true;
    enableZshIntegration = true;
    settings = mergeAllAttrSets [
      enabledModules
      disabledModules
      {
        format = promptFormat;
        palette = "catppuccin_frappe";
        directory = {
          format = "\\[[  $path]($style)\\] ";
          style = "Blue";
          truncation_length = 30;
          truncation_symbol = "…/";
        };
        git_branch = {
          format = "\\[[$symbol$branch(:$remote_branch)]($style)\\] ";
          symbol = " ";
          style = "Muave";
        };
        git_commit = {
          tag_disabled = false;
          only_detached = false;
        };
        git_metrics = {
          format = "([+$added]($added_style) )([-$deleted]($deleted_style) )";
          added_style = "Green";
          deleted_style = "Yellow";
        };
        git_status = {
          style = "Peach";
        };
        aws = {
          style = "Pink";
          symbol = "󰸏 ";
        };
        kubernetes = {
          style = "Sky";
          contexts = [
            {
              context_pattern = ".*prod.*";
              style = "Red";
            }
          ];
        };
        sudo = {
          style = "bold Rosewater";
        };
        nix_shell = {
          style = "Teal";
        };
        character = {
          success_symbol = "[](bold Green) ";
          error_symbol = "[](bold Red) ";
          vimcmd_symbol = "[](bold Mauve) ";
        };
      }
      paletteSet
    ];
  };
}
