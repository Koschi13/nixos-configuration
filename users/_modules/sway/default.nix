{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [ ./env.nix ];

  # TODO move to extra file and import
  #      use let like here to define the package bins
  #      https://github.com/nix-community/home-manager/issues/1521
  home.packages = with pkgs; [
    waybar
    grim
    swaylock-effects
    pamixer
    playerctl
    wl-clipboard
    slurp
  ];

  wayland.windowManager.sway = {
    enable = true;
    systemd.enable = true;
    checkConfig = false;

    # Colors
    extraConfigEarly = ''
      include $HOME/.config/sway/colors/catppuccin-frappe
    '';

    config = {
      modifier = "Mod4"; # Logo key

      left = "j";
      down = "k";
      up = "l";
      right = "Semicolon";

      terminal = "alacritty";

      menu = "rofiWindow"; # See scripts

      bars = [ { command = "${pkgs.waybar}/bin/waybar"; } ];

      # Set colors according to https://github.com/catppuccin/i3
      colors = rec {
        focused = {
          border = "$lavender";
          background = "$base";
          text = "$text";
          indicator = "$rosewater";
          childBorder = "$lavender";
        };
        unfocused = {
          border = "$overlay0";
          background = "$base";
          text = "$text";
          indicator = "$rosewater";
          childBorder = "$overlay0";
        };
        focusedInactive = unfocused;
        urgent = {
          border = "$peach";
          background = "$base";
          text = "$peach";
          indicator = "$overlay0";
          childBorder = "$peach";
        };
        placeholder = {
          border = "$overlay0";
          background = "$base";
          text = "$text";
          indicator = "$overlay0";
          childBorder = "$overlay0";
        };
        background = "$base";
      };

      # It is super important that the left side of the binding does not include any spaces!
      keybindings =
        let
          m = config.wayland.windowManager.sway.config.modifier;
          l = config.wayland.windowManager.sway.config.left;
          r = config.wayland.windowManager.sway.config.right;
          u = config.wayland.windowManager.sway.config.up;
          d = config.wayland.windowManager.sway.config.down;
          term = config.wayland.windowManager.sway.config.terminal;
          menu = config.wayland.windowManager.sway.config.menu;
        in
        lib.mkOptionDefault {
          #
          # System
          #
          "${m}+Shift+q" = "kill";
          "${m}+space" = "exec ${menu}";
          "${m}+Shift+r" = "reload";
          "${m}+r" = "mode 'resize'";

          # Screenshot
          "${m}+p" = ''exec grim -g "$(slurp -d)" - | wl-copy'';
          "${m}+Shift+p" = ''exec grim -g "$(slurp -d)"'';

          # Audio
          "XF86AudioRaiseVolume" = "exec pamixer -i 5";
          "XF86AudioLowerVolume" = "exec pamixer -d 5";
          "XF86AudioMute" = "exec pamixer -t";
          "XF86AudioMicMute" = "exec pamixer --default-source -t";
          "XF86MonBrightnessDown" = "exec light -U 5"; # Installed via system
          "XF86MonBrightnessUp" = "exec light -A 5"; # Installed via system
          "XF86AudioPlay" = "exec playerctl play-pause";
          "XF86AudioPause" = "exec playerctl play-pause";
          "XF86AudioNext" = "exec playerctl next";
          "XF86AudioPrev" = "exec playerctl previous";

          # Lock screen
          # TODO move to script and place in swaylock.nix
          "${m}+Backspace" = "exec ${pkgs.swaylock-effects}/bin/swaylock --screenshots --clock --indicator --indicator-radius 100 --indicator-thickness 7 --effect-blur 7x5 --effect-vignette 0.5:0.5 --ring-color bb00cc --key-hl-color 880033 --line-color 00000000 --inside-color 00000088 --separator-color 00000000 --grace 2 --fade-in 0.2 --ignore-empty-password";

          # Exit sway (logs you out of your Wayland session)
          # TODO move to script in this file
          "${m}+Shift+e" = "exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -b 'Yes, exit sway' 'swaymsg exit'";
          #
          # Moving around:
          #
          # Focus
          "${m}+${l}" = "focus left";
          "${m}+${d}" = "focus down";
          "${m}+${u}" = "focus up";
          "${m}+${r}" = "focus right";

          # Move window
          "${m}+Shift+${l}" = "move left";
          "${m}+Shift+${d}" = "move down";
          "${m}+Shift+${u}" = "move up";
          "${m}+Shift+${r}" = "move right";

          #
          # Workspaces:
          #
          # Switch to workspace
          "${m}+1" = "workspace 1";
          "${m}+2" = "workspace 2";
          "${m}+3" = "workspace 3";
          "${m}+4" = "workspace 4";
          "${m}+5" = "workspace 5";
          "${m}+6" = "workspace 6";
          "${m}+7" = "workspace 7";
          "${m}+8" = "workspace 8";
          "${m}+9" = "workspace 9";
          "${m}+0" = "workspace 10";

          # Move focused container to workspace
          "${m}+Shift+1" = "move container to workspace 1";
          "${m}+Shift+2" = "move container to workspace 2";
          "${m}+Shift+3" = "move container to workspace 3";
          "${m}+Shift+4" = "move container to workspace 4";
          "${m}+Shift+5" = "move container to workspace 5";
          "${m}+Shift+6" = "move container to workspace 6";
          "${m}+Shift+7" = "move container to workspace 7";
          "${m}+Shift+8" = "move container to workspace 8";
          "${m}+Shift+9" = "move container to workspace 9";
          "${m}+Shift+0" = "move container to workspace 10";

          #
          # Layout stuff:
          #
          # You can "split" the current object of your focus with
          # ${modifier}+b or $mod+v, for horizontal and vertical splits
          # respectively.
          "${m}+b" = "splith";
          "${m}+v" = "splitv";

          # Switch the current container between different layout styles
          "${m}+s" = "layout stacking";
          "${m}+w" = "layout tabbed";
          "${m}+e" = "layout toggle split";

          # Make the current focus fullscreen
          "${m}+f" = "fullscreen";

          # Toggle the current focus between tiling and floating mode
          "${m}+Shift+space" = "floating toggle";

          # Swap focus between the tiling area and the floating area
          "${m}+i" = "focus mode_toggle";

          # Move focus to the parent container
          "${m}+a" = "focus parent";

          #
          # Applications
          #
          "${m}+Return" = "exec ${term}";
        };

      modes =
        let
          l = config.wayland.windowManager.sway.config.left;
          r = config.wayland.windowManager.sway.config.right;
          u = config.wayland.windowManager.sway.config.up;
          d = config.wayland.windowManager.sway.config.down;
        in
        {
          "resize" = {
            # left will shrink the containers width
            "${l}" = "resize shrink width 25px";
            # down will grow the containers height
            "${d}" = "resize grow height 25px";
            # up will shrink the containers height
            "${u}" = "resize shrink height 25px";
            # right will grow the containers width
            "${r}" = "resize grow width 25px";

            # Return to default mode
            "Return" = "mode 'default'";
            "Escape" = "mode 'default'";
          };
        };

      window = {
        border = 2;
        commands = [
          {
            command = "border pixel 0";
            criteria = {
              app_id = "^.*";
            };
          }
          {
            command = "border pixel 0";
            criteria = {
              class = "^.*";
            };
          }
        ];
      };

      gaps = {
        smartGaps = true;
        smartBorders = "on";
        inner = 10;
        outer = 10;
      };

      input = {
        "type:keyboard" = {
          xkb_layout = "us,de";
          xkb_variant = ",nodeadkeys";
          xkb_options = "ctrl:nocaps";
        };
      };

      # Drag floating windows by holding down ${modifier} and left mouse button.
      # Resize them with right mouse button + ${modifier}.
      # Despite the name, also works for non-floating windows.
      # Change normal to inverse to use left mouse button for resizing and right
      # mouse button for dragging.
      floating =
        let
          m = config.wayland.windowManager.sway.config.modifier;
        in
        lib.mkOptionDefault {
          modifier = "${m} normal";
          criteria = [
            { title = "Emulator"; }
            { title = "Android Emulator"; }
            { app_id = "pavucontrol"; }
          ];
        };

      startup = [
        {
          command = "command -v swww >/dev/null 2>&1 && swww init & sleep 0.5 && exec wallpaper_random || echo 'swww not installed'";
        }
      ];
    };
  };

  home.file.".config/sway/colors/catppuccin-frappe" = {
    # TODO: utilize flake and let it decide the hash
    source = builtins.fetchurl {
      url = "https://raw.githubusercontent.com/catppuccin/i3/main/themes/catppuccin-frappe";
      sha256 = "75b0e063b0ff670173641cb5fb456052af84b78774f77c37b6c3a886fc809c51";
    };
  };
}
