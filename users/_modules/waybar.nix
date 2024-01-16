{ config, lib, pkgs, ... }:

{
    programs.waybar = {
      enable = true;
      systemd = {
        enable = false;
        target = "graphical-session.target";
      };
      style = ''
        * {
          font-family: "DejaVuSansMono Nerd Font Mono";
          font-size: 12pt;
          font-weight: bold;
          /* Disabled for sway
	  border-radius: 8px;
	  */
          transition-property: background-color;
          transition-duration: 0.5s;
        }
        @keyframes blink_red {
          to {
            background-color: rgb(242, 143, 173);
            color: rgb(26, 24, 38);
          }
        }
        .warning, .critical, .urgent {
          animation-name: blink_red;
          animation-duration: 1s;
          animation-timing-function: linear;
          animation-iteration-count: infinite;
          animation-direction: alternate;
        }
        window#waybar {
          background-color: transparent;
        }
        window > box {
          /* Disabled for sway
	  margin-left: 5px;
          margin-right: 5px;
          margin-top: 5px;
	  */
          background-color: #1e1e2a;
          padding: 3px;
          padding-left:8px;
          /* Disabled for sway
	  border: 2px none #33ccff;
	  */
        }
        #workspaces {
          padding-left: 0px;
          padding-right: 4px;
        }
        #workspaces button {
          padding-top: 5px;
          padding-bottom: 5px;
          padding-left: 6px;
          padding-right: 6px;
        }
        #workspaces button.active {
          background-color: rgb(181, 232, 224);
          color: rgb(26, 24, 38);
        }
        #workspaces button.urgent {
          color: rgb(26, 24, 38);
        }
        #workspaces button:hover {
          background-color: rgb(248, 189, 150);
          color: rgb(26, 24, 38);
        }
        tooltip {
          background: rgb(48, 45, 65);
        }
        tooltip label {
          color: rgb(217, 224, 238);
        }
        #custom-launcher {
          font-size: 20px;
          padding-left: 8px;
          padding-right: 6px;
          color: #7ebae4;
        }
        #mode, #clock, #memory, #temperature,#cpu, #custom-wall, #temperature, #backlight, #pulseaudio, #battery, #network, #custom-powermenu {
          padding-left: 10px;
          padding-right: 10px;
        }
        #memory {
          color: rgb(181, 232, 224);
        }
        #cpu {
          color: rgb(245, 194, 231);
        }
        #clock {
          color: rgb(217, 224, 238);
        }
        #custom-wall {
          color: #33ccff;
        }
        #temperature {
          color: rgb(150, 205, 251);
        }
        #backlight {
          color: rgb(248, 189, 150);
        }
        #pulseaudio {
          color: rgb(245, 224, 220);
        }
        #battery {
          color: #00cc00;
        }
        #battery.warning {
          color: #ff9900;
        }
        #battery.critical {
          color: #ff3300;
        }
        #network {
          color: #ABE9B3;
        }
        #network.disconnected {
          color: rgb(255, 255, 255);
        }
        #custom-powermenu {
          color: rgb(242, 143, 173);
          padding-right: 8px;
        }
        #tray {
          padding-right: 8px;
          padding-left: 10px;
        }
      '';
      settings = [{
        "layer" = "top";
        "position" = "top";
        modules-left = [
          "custom/launcher"
	  "battery"
          "memory"
          "cpu"
          "temperature"
        ];
        modules-center = [
          "clock"
        ];
        modules-right = [
          "pulseaudio"
          "backlight"
          "network"
          "custom/powermenu"
          "tray"
        ];
        "custom/launcher" = {
          "format" = " ";
          "on-click" = "pkill rofi || rofi2";
          "on-click-middle" = "exec default_wall";
          "on-click-right" = "exec wallpaper_random";
          "tooltip" = false;
        };
        "pulseaudio" = {
          "scroll-step" = 1;
          "format" = "{icon} {volume}%";
          "format-muted" = "󰖁 Muted";
          "format-icons" = {
            "default" = [ "" "" "" ];
          };
          "on-click" = "pamixer -t";
          "tooltip" = false;
        };
        "clock" = {
          "interval" = 1;
          "format" = "{:%I:%M %p  %A %b %d}";
          "tooltip" = true;
          "tooltip-format"= "{=%A; %d %B %Y}\n<tt>{calendar}</tt>";
        };
        "memory" = {
          "interval" = 1;
          "format" = "󰻠 {percentage}%";
          "states" = {
            "warning" = 85;
          };
        };
        "cpu" = {
          "interval" = 1;
          "format" = "󰍛 {usage}%";
        };
        "network" = {
          "format-disconnected" = "󰯡 Disconnected";
          "format-ethernet" = "󰒢 Connected!";
          "format-linked" = "󰖪 {essid} (No IP)";
          "format-wifi" = "󰖩 {essid}";
          "interval" = 1;
          "tooltip" = false;
        };
        "custom/powermenu" = {
          "format" = "";
          "on-click" = "pkill rofi || ~/.config/rofi/powermenu/type-3/powermenu.sh";
          "tooltip" = false;
        };
        "tray" = {
          "icon-size" = 15;
          "spacing" = 5;
        };
        "battery" = {
          "states" = {
            "warning" = 30;
            "critical" = 15;
          };
          "format" = "{icon} {capacity}%";
          "format-plugged" = "󱊦 {capacity}%";
          "format-alt" = "{time} {icon}";
          "format-icons" = ["󰂎" "󱊡" "󱊢" "󱊣"];
	};
      }];
    };
}
