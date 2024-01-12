{ config, lib, pkgs, ... }:

{
  imports = [
    ./env.nix
  ];

  home.packages = with pkgs; [
    waybar
    swww
    grim
    swaylock-effects
    pamixer
    light
    playerctl
  ];

  #test later systemd.user.targets.hyprland-session.Unit.Wants = [ "xdg-desktop-autostart.target" ];
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;

    # enableNvidiaPatches = true;
    extraConfig = ''
    # AOC desktop
    monitor=desc:AOC U34G2G4R3 0x00002347,3440x1440@144,1440x0,1
    # Laptop screen
    monitor=desc:California Institute of Technology 0x1402,2880x1800@90,0x0,2
    # change monitor to high resolution, the last argument is the scale factor
    monitor=,highres,auto,2

    # toolkit-specific scale
    env = GDK_SCALE,2
    env = XCURSOR_SIZE,32

    # Fix slow startup
    # exec systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
    # exec dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP 

    # Autostart

    #exec-once = hyprctl setcursor Bibata-Modern-Classic 24
    exec-once = dunst

    source = /home/max/.config/hypr/colors/frappe.conf
    exec = pkill waybar & sleep 0.5 && waybar
    # exec-once = swww init & sleep 0.5 && exec wallpaper_random
    # exec-once = swww img /home/max/Images/wallpapers/xxx.png

    input {
        kb_options=ctrl:nocaps
    }

    general {
        gaps_in = 5
        gaps_out = 20
        border_size = 2
        col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
        col.inactive_border = rgba(595959aa)

        layout = dwindle
    }

    decoration {
        rounding = 10
	blur {
	    enabled = true
            size = 3
            passes = 1
            new_optimizations = true
	}

        drop_shadow = true
        shadow_range = 4
        shadow_render_power = 3
        col.shadow = rgba(1a1a1aee)
    }

    animations {
        enabled = yes

        bezier = ease,0.4,0.02,0.21,1

        animation = windows, 1, 3.5, ease, slide
        animation = windowsOut, 1, 3.5, ease, slide
        animation = border, 1, 6, default
        animation = fade, 1, 3, ease
        animation = workspaces, 1, 3.5, ease
    }

    dwindle {
        pseudotile = yes
        preserve_split = yes
    }

    master {
        new_is_master = yes
    }

    gestures {
        workspace_swipe = false
    }

    xwayland {
      force_zero_scaling = true
    }

    # Example windowrule v1
    # windowrule = float, ^(kitty)$
    # Example windowrule v2
    # windowrulev2 = float,class:^(kitty)$,title:^(kitty)$

    #windowrule=float,^(kitty)$
    #windowrule=center,^(kitty)$
    #windowrule=size 600 500,^(kitty)$
    windowrule=float,^(pavucontrol)$
    windowrule=float,^(blueman-manager)$
    #windowrule=size 934 525,^(mpv)$
    #windowrule=float,^(mpv)$
    #windowrule=center,^(mpv)$
    #windowrulev2=center,class:^jetbrains-pycharm$,title:^Settings$
    #windowrulev2=size 600 500,class:^jetbrains-pycharm$,title:^Settings$
    # Fix Pycharm flickering -> https://github.com/hyprwm/Hyprland/issues/2412
    windowrulev2=nofocus,class:^jetbrains-(?!toolbox),floating:1,title:^win\d+$

    $mainMod = SUPER
    bind = $mainMod, F, fullscreen,

    #bind = $mainMod, RETURN, exec, cool-retro-term-zsh
    bind = $mainMod, RETURN, exec, alacritty
    bind = $mainMod, B, exec, firefox
    bind = $mainMod SHIFT, Q, killactive,
    bind = $mainMod SHIFT ALT, E, exit,
    bind = $mainMod, M, exec, nautilus
    bind = $mainMod, V, togglefloating,
    bind = $mainMod, SPACE, exec, rofiWindow
    #bind = $mainMod, P, pseudo, # dwindle
    bind = $mainMod, E, togglesplit, # dwindle
    bind = $mainMod, W, togglegroup,
    bind = $mainMod SHIFT, W, changegroupactive,
    bind = $mainMod, BACKSPACE, exec, swaylock --screenshots --clock --indicator --indicator-radius 100 --indicator-thickness 7 --effect-blur 7x5 --effect-vignette 0.5:0.5 --ring-color bb00cc --key-hl-color 880033 --line-color 00000000 --inside-color 00000088 --separator-color 00000000 --grace 2 --fade-in 0.2 --ignore-empty-password

    # Switch Keyboard Layouts
    # bind = $mainMod, SPACE, exec, hyprctl switchxkblayout teclado-gamer-husky-blizzard next

    bind = , Print, exec, grim -g "$(slurp)" - | wl-copy
    bind = SHIFT, Print, exec, grim -g "$(slurp)"

    # Functional keybinds
    bind =,XF86AudioMicMute,exec,pamixer --default-source -t
    bind =,XF86MonBrightnessDown,exec,light -U 5
    bind =,XF86MonBrightnessUp,exec,light -A 5
    bind =,XF86AudioMute,exec,pamixer -t
    bind =,XF86AudioLowerVolume,exec,pamixer -d 5
    bind =,XF86AudioRaiseVolume,exec,pamixer -i 5
    bind =,XF86AudioPlay,exec,playerctl play-pause
    bind =,XF86AudioPause,exec,playerctl play-pause

    # to switch between windows in a floating workspace
    bind = SUPER,Tab,cyclenext,
    bind = SUPER,Tab,bringactivetotop,

    bind = $mainMod, J, movefocus, l
    bind = $mainMod, SEMICOLON, movefocus, r
    bind = $mainMod, K, movefocus, u
    bind = $mainMod, L, movefocus, d

    bind = $mainMod SHIFT, J, movewindow, l
    bind = $mainMod SHIFT, SEMICOLON, movewindow, r
    bind = $mainMod SHIFT, K, movewindow, u
    bind = $mainMod SHIFT, L, movewindow, d

    bind = $mainMod ALT, J, moveintogroup, l
    bind = $mainMod ALT, SEMICOLON, moveintogroup, r
    bind = $mainMod ALT, K, moveintogroup, u
    bind = $mainMod ALT, L, moveintogroup, d

    bind = $mainMod SHIFT ALT, J, moveoutofgroup, l
    bind = $mainMod SHIFT ALT, SEMICOLON, moveoutofgroup, r
    bind = $mainMod SHIFT ALT, K, moveoutofgroup, u
    bind = $mainMod SHIFT ALT, L, moveoutofgroup, d

    bind = $mainMod, 1, workspace, 1
    bind = $mainMod, 2, workspace, 2
    bind = $mainMod, 3, workspace, 3
    bind = $mainMod, 4, workspace, 4
    bind = $mainMod, 5, workspace, 5
    bind = $mainMod, 6, workspace, 6
    bind = $mainMod, 7, workspace, 7
    bind = $mainMod, 8, workspace, 8
    bind = $mainMod, 9, workspace, 9
    bind = $mainMod, 0, workspace, 10

    # Move active window to a workspace with mainMod + SHIFT + [0-9]
    bind = $mainMod SHIFT, 1, movetoworkspace, 1
    bind = $mainMod SHIFT, 2, movetoworkspace, 2
    bind = $mainMod SHIFT, 3, movetoworkspace, 3
    bind = $mainMod SHIFT, 4, movetoworkspace, 4
    bind = $mainMod SHIFT, 5, movetoworkspace, 5
    bind = $mainMod SHIFT, 6, movetoworkspace, 6
    bind = $mainMod SHIFT, 7, movetoworkspace, 7
    bind = $mainMod SHIFT, 8, movetoworkspace, 8
    bind = $mainMod SHIFT, 9, movetoworkspace, 9
    bind = $mainMod SHIFT, 0, movetoworkspace, 10

    # Scroll through existing workspaces with mainMod + scroll
    #bind = $mainMod, mouse_down, workspace, e+1
    #bind = $mainMod, mouse_up, workspace, e-1

    # Move/resize windows with mainMod + LMB/RMB and dragging
    bindm = $mainMod, mouse:272, movewindow
    bindm = $mainMod, mouse:273, resizewindow
    bindm = ALT, mouse:272, resizewindow
        '';
  };

  home.file.".config/hypr/colors/frappe.conf" = {
    source = builtins.fetchurl {
      url = "https://github.com/catppuccin/hyprland/releases/download/v1.2/frappe.conf";
      sha256 = "927a528d42ad435b6c3a8b538bf7be38c74709c860048ded49ad78f1d17752a0";
    };
  };
}
