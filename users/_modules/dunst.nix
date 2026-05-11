{pkgs, ...}: {
  services.dunst = {
    enable = true;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    settings = {
      global = {
        alignment = "left";
        always_run_script = true;
        browser = "${pkgs.firefox} --new-tab";
        corner_radius = 10;
        ellipsize = "middle";
        enable_posix_regex = true;
        follow = "mouse";
        font = "NotoSansM Nerd Font Mono 10";
        format = "<b>%s</b>\\n%b"; # format = "<span foreground='#f3f4f5'><b>%s %p</b></span>\n%b"
        frame_color = "#232323";
        frame_width = 1;
        fullscreen = "delay";
        gap_size = 0;
        height = "(20,200)";
        history_length = 20;
        horizontal_padding = 10;
        icon_position = "left";
        idle_threshold = 120;
        ignore_newline = "no";
        indicate_hidden = "yes";
        line_height = 0;
        markup = "full";
        max_icon_size = 64;
        min_icon_size = 0;
        monitor = "0";
        mouse_left_click = "do_action, close_current";
        mouse_middle_click = "close_current";
        mouse_right_click = "close_all";
        offset = "(0x15)";
        origin = "bottom-center";
        padding = 10;
        plain_text = "no";
        progress_bar = true;
        rounded = "yes";
        separator_color = "frame";
        separator_height = 2;
        show_age_threshold = 60;
        show_indicators = "yes";
        shrink = "no";
        sort = "yes";
        stack_duplicates = true;
        sticky_history = "yes";
        text_icon_padding = 0;
        timeout = 30;
        transparency = 0;
        vertical_alignment = "center";
        width = "(200,400)";
        word_wrap = "yes";
      };

      outlook_calendar = {
        # filter
        summary = ".*Outlook Calendar.*";

        # change
        urgency = "critical";

        # settings
        fullscreen = "show";
        overwrite_pause_level = 101; # always come through
      };

      urgency_critical = {
        background = "#e78284"; # Red
        foreground = "#c6d0f5"; # Text
        timeout = 0; # Require user interaction to dismiss
      };

      urgency_low = {
        background = "#414559"; # Surface 0
        foreground = "#c6d0f5"; # Text
        timeout = 5;
      };

      urgency_normal = {
        background = "#626880"; # Surface 2
        foreground = "#c6d0f5"; # Text
      };
    };
  };
}
