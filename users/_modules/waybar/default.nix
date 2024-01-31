{ config, lib, pkgs, ... }:

{
  programs.waybar = {
    enable = true;
    systemd = {
      enable = false;
      target = "graphical-session.target";
    };
    style = (builtins.readFile ./style.css);
    settings = [{
      "layer" = "top";
      "position" = "top";
      modules-left =
        [ "custom/launcher" "battery" "memory" "cpu" "temperature" ];
      modules-center = [ "clock" ];
      modules-right =
        [ "pulseaudio" "backlight" "network" "custom/powermenu" "tray" ];
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
        "format-icons" = { "default" = [ "" "" "" ]; };
        "on-click" = "pamixer -t";
        "tooltip" = false;
      };
      "clock" = {
        "interval" = 1;
        "format" = "{:%I:%M %p  %A %b %d}";
        "tooltip" = true;
        "tooltip-format" = "<tt><small>{calendar}</small></tt>";
        "calendar" = {
          "mode" = "year";
          "mode-mon-col" = 3;
          "weeks-pos" = "right";
          "on-scroll" = 1;
          "on-click-right" = "mode";
          "format" = {
            "months" = "<span color='#ffead3'><b>{}</b></span>";
            "days" = "<span color='#ecc6d9'><b>{}</b></span>";
            "weeks" = "<span color='#99ffdd'><b>W{}</b></span>";
            "weekdays" = "<span color='#ffcc66'><b>{}</b></span>";
            "today" = "<span color='#ff6699'><b><u>{}</u></b></span>";
          };
        };
      };
      "memory" = {
        "interval" = 1;
        "format" = "󰻠 {percentage}%";
        "states" = { "warning" = 85; };
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
        "on-click" =
          "pkill rofi || ~/.config/rofi/powermenu/type-3/powermenu.sh";
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
        "format-icons" = [ "󰂎" "󱊡" "󱊢" "󱊣" ];
      };
    }];
  };
}
