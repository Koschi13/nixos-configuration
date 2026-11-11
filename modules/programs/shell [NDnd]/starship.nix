{self, ...}: {
  flake.modules.homeManager.shell = {
    lib,
    pkgs,
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
      promptPrefix = "[](base08)";
      promptOneStyle = "bg:base08 fg:base11";
      promptOne = ["os" "username" "hostname" "sudo"];
      promptOneSeparator = "[](bg:base09 fg:base08)";

      promptTwoStyle = "bg:base09 fg:base11";
      promptTwo = ["directory"];
      promptTwoSeparator = "[](bg:base0a fg:base09)";

      promptThreeStyle = "fg:base11 bg:base0a";
      promptThree = ["git_branch" "git_commit" "git_state" "git_metrics" "git_status"];
      promptThreeSeparator = "[](fg:base0a bg:base0b)";

      promptFourStyle = "fg:base11 bg:base0b";
      promptFour = ["python" "rust" "golang" "nodejs" "zig"];
      promptFourSeparator = "[](fg:base0b bg:base16)";

      promptFiveStyle = "fg:base11 bg:base16";
      promptFive = ["aws" "kubernetes"];
      promptFiveSeparator = "[](fg:base16 bg:base07)";

      promptSixStyle = "fg:base11 bg:base07";
      promptSix = ["status" "time"];
      promptSixSeparator = "[](fg:base07)";

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
    in {
      # Defines the palette the prompt uses (`base00`…`base17`). Starship ignores uppercase
      # color names, so `base0A`…`base0F` are written `base0a`…`base0f`
      imports = [self.modules.homeManager.stylix];
      stylix.targets.starship.enable = true;

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

            # Directly after the username: `max@fabricator`
            hostname = {
              ssh_only = false;
              style = promptOneStyle;
              format = "[@$hostname]($style)";
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
              home_symbol = "";
              truncate_to_repo = false;

              substitutions = {
                "/Documents" = "󰈙";
                "/Downloads" = "";
                "/Music" = "󰝚";
                "/Pictures" = "";
                "/Git/GitHub" = "";
                "/.config" = "";
                "/.dotfiles" = "";
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
              format = "[ \\($state( $progress_current/$progress_total)\\)]($style)";
              style = promptThreeStyle;
            };

            git_metrics = {
              format = "([ +$added]($added_style))([ -$deleted]($deleted_style))";
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
              format = "[ $symbol( $version)( \(#$virtualenv\))]($style)";
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
              format = "[ $symbol( $version)]($style)";
            };

            zig = {
              symbol = "";
              format = "[ $symbol( $version)]($style)";
              style = promptFourStyle;
            };

            #######################################################################
            # Prompt Five
            #######################################################################
            aws = {
              style = promptFiveStyle;
              format = "[ $symbol( $profile on)( \\($region\\))( \\[$duration\\])]($style)";
              symbol = "󰸏";
              force_display = true;
            };

            kubernetes = {
              style = promptFiveStyle;
              format = "[ $symbol ($user on )($cluster in )$context( \\($namespace\\))]($style)";
              contexts = [
                {
                  context_pattern = ".*prod.*";
                  style = "bold fg:base08 bg:base16";
                }
              ];
              detect_env_vars = ["AWS_SECRET_ACCESS_KEY"];
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
              style = "base0c";
              format = "[in $symbol]($style) ";
              symbol = "❄️";
            };

            character = {
              success_symbol = "[[󰄛](base0b) ❯](base09)";
              error_symbol = "[[󰄛](base08) ❯](base09)";
              vimcmd_symbol = "[](base05)";
            };

            # continuation_prompt = "[▶▶ ](fg:base07)"; # TODO: doesn't work
          }
        ];
      };
    };
}
