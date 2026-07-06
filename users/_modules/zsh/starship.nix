{
  lib,
  pkgs,
  catppuccinStarship,
  ...
}:
with lib;
with builtins; let
  starshipPackage = pkgs.starship;

  ##############################################################################
  # Helper functions
  ##############################################################################
  # `cc.rs` is no module
  isModuleFile = path: type: hasSuffix ".rs" path && type == "regular" && path != "mod.rs" && path != "cc.rs";
  mergeAllAttrSets = attrsSets: foldl' recursiveUpdate {} attrsSets;
  # Set a module to `disable = true`
  disableModules = isDisabled: modules: mergeAllAttrSets (map (mod: {"${mod}".disabled = isDisabled;}) modules);

  ##############################################################################
  # Prompt
  ##############################################################################
  promptPrefix = "[](red)";
  promptOne = ["os" "username" "sudo"];
  promptOneSeparator = "[](bg:peach fg:red)";
  promptTwo = ["directory"];
  promptTwoSeparator = "[](bg:yellow fg:peach)";
  promptThree = ["git_branch" "git_commit" "git_state" "git_metrics" "git_status"];
  promptThreeSeparator = "[](fg:yellow bg:green)";
  promptFour = ["python" "rust" "golang" "nodejs" "zig"];
  promptFourSeparator = "[](fg:green bg:sapphire)";
  promptFive = ["aws" "kubernetes"];
  promptFiveSeparator = "[](fg:sapphire bg:lavender)";
  promptSix = ["status" "time"];
  promptSixSeparator = "[ ](fg:lavender)";
  promptSeven = ["cmd_duration" "line_break" "nix_shell" "character"];

  promptModules = [promptOne promptTwo promptThree promptFour promptFive promptSix promptSeven];
  promptCharacters = [promptPrefix promptOneSeparator promptTwoSeparator promptThreeSeparator promptFourSeparator promptFiveSeparator promptSixSeparator];
  promptModulesFlat = concatLists promptModules;
  promptFormat = concatStrings (lib.lists.zipListsWith (c: m: "${c}" + concatStrings (map (ms: "\$${ms}") m)) promptCharacters promptModules);

  ##############################################################################
  # Initial module config
  ##############################################################################
  modulesSources = readDir "${starshipPackage.src}/src/modules";
  enabledModules = disableModules false promptModulesFlat; # <== enabled all modules used in the prompt are enabled
  disabledModules = pipe modulesSources [
    # <== from starship's sources…
    (filterAttrs isModuleFile) # <== keep only Module files…
    attrNames # <== get the filenames…
    (map (removeSuffix ".rs")) # <== remove Rust source extension…
    (subtractLists promptModulesFlat) # <== do not disable modules used in the prompt…
    (disableModules true) # <== and finally build the configuration
  ];

  ##############################################################################
  # Theme
  ##############################################################################
  paletteSet = fromTOML (
    readFile (
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
        "$schema" = "https://starship.rs/config-schema.json";
        format = promptFormat;
        palette = "catppuccin_frappe";

        directory = {
          style = "bg:peach fg:crust";
          format = "[ $path]($style)";
          truncation_length = 9;
          truncation_symbol = "…/";

          substitutions = {
            "Documents" = "󰈙 ";
            "Downloads" = " ";
            "Music" = "󰝚 ";
            "Pictures" = " ";
            "Git" = " ";
            ".config" = " ";
            ".dotfiles" = " ";
          };
        };

        git_branch = {
          format = "[ $symbol $branch]($style)";
          symbol = "";
          style = "fg:crust bg:yellow";
        };

        git_commit = {
          format = "[ \\($hash$symbol$tag\\)]($style)";
          tag_disabled = false;
          only_detached = false;
          style = "fg:crust bg:yellow";
        };

        git_metrics = {
          format = "([ {+$added]($added_style))([ -$deleted}]($deleted_style))($style)";

          added_style = "fg:crust bg:yellow";
          deleted_style = "fg:crust bg:yellow";
          style = "bg:yellow";
        };

        git_status = {
          style = "fg:crust bg:yellow";
          format = "[ $all_status$ahead_behind]($style)";
        };

        aws = {
          style = "pink";
          symbol = "󰸏 ";
        };

        kubernetes = {
          style = "sky";
          contexts = [
            {
              context_pattern = ".*prod.*";
              style = "bold red";
            }
          ];
        };

        sudo = {
          style = "bold bg:red fg:crust";
          format = "[ as $symbol]($style)";
        };

        nix_shell = {
          style = "teal";
        };

        character = {
          success_symbol = "[[󰄛](green) ❯](peach)";
          error_symbol = "[[󰄛](red) ❯](peach)";
          vimcmd_symbol = "[](subtext1)";
        };

        cmd_duration = {
          show_milliseconds = true;
          format = " in $duration ";
          min_time_to_notify = 45000;
        };

        time = {
          time_format = "%R";
          style = "fg:crust bg:lavender";
          format = "[  $time]($style)";
        };

        status = {
          format = "[ $symbol$status]($style)";
          style = "fg:crust bg:lavender";
          success_symbol = "✅";
          pipestatus = true;
          pipestatus_format = "[ \\[$pipestatus\\]]($style)";
          pipestatus_segment_format = "[$symbol$status]($style)";
        };

        username = {
          show_always = true;
          style_user = "bg:red fg:crust";
          style_root = "bold bg:red fg:crust";
          format = "[ $user]($style)";
        };

        os = {
          style = "bg:red fg:crust";
        };

        python = {
          symbol = "";
          style = "fg:crust bg:green";
          format = "[ $symbol( $version)(\(#$virtualenv\))]($style)";
        };

        golang = {
          symbol = "";
          style = "fg:crust bg:green";
          format = "[ $symbol( $version)]($style)";
        };

        rust = {
          symbol = "";
          style = "fg:crust bg:green";
          format = "[ $symbol( $version)]($style)";
        };

        # continuation_prompt = "[▶▶ ](fg:lavender)"; # TODO: doesn't work
      }
      paletteSet
    ];
  };
}
