{ config, lib, pkgs, ... }:

# TODO: find a way to share the common stuff with sway
let
  l = "j";          # left
  d = "k";          # down
  u = "l";          # up
  r = "semicolon";  # right
  i3lock-color-lock = pkgs.writeShellScriptBin "i3lock-color-lock" (builtins.readFile ./i3lock-color-lock.sh);
in {
  imports = [ ./env.nix ];

  home.packages = with pkgs; [
    pamixer
    maim
    xclip
    playerctl
    i3lock-color
    i3lock-color-lock
  ];

  xsession.windowManager.i3 = {
    enable = true;
    package = pkgs.i3-gaps;

    # Colors
    extraConfig = ''
      include $HOME/.config/i3/colors/catppuccin-frappe
    '';

    config = {
      modifier = "Mod4"; # Logo key

      terminal = "alacritty";

      menu = "rofiWindow"; # See rofi/default.nix


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
      keybindings = let
        m = config.xsession.windowManager.i3.config.modifier;
        term = config.xsession.windowManager.i3.config.terminal;
        menu = config.xsession.windowManager.i3.config.menu;
      in lib.mkOptionDefault {
        #
        # System
        #
        "${m}+Shift+q" = "kill";
        "${m}+space" = "exec ${menu}";
        "${m}+Shift+r" = "reload";
        "${m}+r" = "mode 'resize'";

        # Screenshot
        "${m}+p" = ''exec --no-startup-id maim --select | xclip -selection clipboard -t image/png'';
        "${m}+Shift+p" = ''exec --no-startup-id maim | xclip -selection clipboard -t image/png"'';

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
        "${m}+BackSpace" = "exec i3lock-color-lock";

        # Exit xfce managed i3 session
        "${m}+Shift+e" = "i3-nagbar -t warning -m 'Do you want to exit i3?' -b 'Yes' 'xfce4-session-logout'";

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

      modes = {
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
        border = 0;
        commands = [
          {
            command = "border pixel 0";
            criteria = { class = "^.*"; };
          }
        ];
      };

      gaps = {
        smartGaps = true;
        smartBorders = "on";
        inner = 10;
        outer = 10;
      };

      # Drag floating windows by holding down ${modifier} and left mouse button.
      # Resize them with right mouse button + ${modifier}.
      # Despite the name, also works for non-floating windows.
      # Change normal to inverse to use left mouse button for resizing and right
      # mouse button for dragging.
      floating = let
        m = config.xsession.windowManager.i3.config.modifier;
      in lib.mkOptionDefault {
        modifier = "${m}";
        criteria = [
          { title = "Emulator"; }
          { title = "Android Emulator"; }
          { class = "Pavucontrol"; }
        ];
      };

      # TODO: Replace with x11 package
      #startup = [{
      #  command =
      #    "command -v swww >/dev/null 2>&1 && swww init & sleep 0.5 && exec wallpaper_random || echo 'swww not installed'";
      #}];
    };
  };

  home.file.".config/i3/colors/catppuccin-frappe" = {
    # TODO: utilize flake and let it decide the hash
    source = builtins.fetchurl {
      url =
        "https://raw.githubusercontent.com/catppuccin/i3/main/themes/catppuccin-frappe";
      sha256 =
        "75b0e063b0ff670173641cb5fb456052af84b78774f77c37b6c3a886fc809c51";
    };
  };
}
