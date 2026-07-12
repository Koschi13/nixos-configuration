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
  promptOneStyle = "bg:red fg:crust";
  promptOne = ["os" "username" "sudo"];
  promptOneSeparator = "[](bg:peach fg:red)";

  promptTwoStyle = "bg:peach fg:crust";
  promptTwo = ["directory"];
  promptTwoSeparator = "[](bg:yellow fg:peach)";

  promptThreeStyle = "fg:crust bg:yellow";
  promptThree = ["git_branch" "git_commit" "git_state" "git_metrics" "git_status"];
  promptThreeSeparator = "[](fg:yellow bg:green)";

  promptFourStyle = "fg:crust bg:green";
  promptFour = ["python" "rust" "golang" "nodejs" "zig"];
  promptFourSeparator = "[](fg:green bg:sapphire)";

  promptFiveStyle = "fg:crust bg:sapphire";
  promptFive = ["aws" "kubernetes"];
  promptFiveSeparator = "[](fg:sapphire bg:lavender)";

  promptSixStyle = "fg:crust bg:lavender";
  promptSix = ["status" "time"];
  promptSixSeparator = "[](fg:lavender)";

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

        #######################################################################
        # Prompt One
        #######################################################################
        os = {
          style = promptOneStyle;
        };

        username = {
          show_always = true;
          style_user = promptOneStyle;
          style_root = "bold ${promptOneStyle}";
          format = "[ $user]($style)";
        };

        sudo = {
          style = "bold ${promptOneStyle}";
          format = "[ as $symbol]($style)";
        };

        #######################################################################
        # Prompt Two
        #######################################################################
        directory = {
          style = promptTwoStyle;
          format = "[ $path]($style)";
          truncation_length = 9;
          truncation_symbol = "…/";

          substitutions = {
            "Documents" = "󰈙";
            "Downloads" = "";
            "Music" = "󰝚";
            "Pictures" = "";
            "~/Git/GitHub" = "";
            ".config" = "";
            ".dotfiles" = "";
            "~" = "";
          };
        };

        #######################################################################
        # Prompt Three
        #######################################################################
        git_branch = {
          format = "[ $symbol $branch]($style)";
          symbol = "";
          style = promptThreeStyle;
        };

        git_commit = {
          format = "[ \\($hash$symbol$tag\\)]($style)";
          tag_disabled = false;
          only_detached = false;
          style = promptThreeStyle;
        };

        git_state = {
          style = promptThreeStyle;
        };

        git_metrics = {
          format = "([ {+$added]($added_style))([ -$deleted}]($deleted_style))";
          added_style = promptThreeStyle;
          deleted_style = promptThreeStyle;
        };

        git_status = {
          style = promptThreeStyle;
          format = "[ $all_status$ahead_behind]($style)";
        };

        #######################################################################
        # Prompt Four
        #######################################################################
        python = {
          symbol = "";
          style = promptFourStyle;
          format = "[ $symbol( $version)(\(#$virtualenv\))]($style)";
        };

        rust = {
          symbol = "";
          style = promptFourStyle;
          format = "[ $symbol( $version)]($style)";
        };

        golang = {
          symbol = "";
          style = promptFourStyle;
          format = "[ $symbol( $version)]($style)";
        };

        nodejs = {
          symbol = "󰎙";
          style = promptFourStyle;
          format = "[[ $symbol( $version) ](fg:crust bg:green)]($style)";
        };

        zig = {
          symbol = "";
          style = promptFourStyle;
        };

        #######################################################################
        # Prompt Five
        #######################################################################
        aws = {
          style = promptFiveStyle;
          symbol = "󰸏";
        };

        kubernetes = {
          style = promptFiveStyle;
          contexts = [
            {
              context_pattern = ".*prod.*";
              style = "bold fg:red bg:sapphire";
            }
          ];
        };

        #######################################################################
        # Prompt Six
        #######################################################################
        status = {
          format = "[ \\[$symbol$status\\]]($style)";
          style = promptSixStyle;
          pipestatus = true;
          pipestatus_format = "[ \\[$pipestatus\\]]($style)";
          pipestatus_segment_format = "[$symbol$status]($style)";
        };

        time = {
          time_format = "%R";
          style = promptSixStyle;
          format = "[  $time]($style)";
        };

        #######################################################################
        # Prompt Seven
        #######################################################################
        cmd_duration = {
          show_milliseconds = true;
          format = "  in $duration";
          min_time_to_notify = 45000;
        };

        nix_shell = {
          style = "teal";
          format = "[in $symbol]($style) ";
          symbol = "❄️";
        };

        character = {
          success_symbol = "[[󰄛](green) ❯](peach)";
          error_symbol = "[[󰄛](red) ❯](peach)";
          vimcmd_symbol = "[](subtext1)";
        };

        # continuation_prompt = "[▶▶ ](fg:lavender)"; # TODO: doesn't work
      }
      paletteSet
    ];
  };
}
