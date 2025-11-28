{lib, ...}: {
  programs.mangohud = {
    enable = true;

    settings = {
      core_bars = 1;
      core_load = 1;
      cpu_color = lib.mkDefault "AAAAAA";
      cpu_stats = 1;
      cpu_temp = 1;
      fps = 1;
      fps_limit = "144,120,90,60,0";
      frame_timing = 1;
      frametime = 1;
      gamemode = 1;
      gpu_color = lib.mkDefault "AAAAAA";
      gpu_power = 1;
      gpu_temp = 1;
      # horizontal = 1;
      round_corners = 7;
      table_columns = 2;
      text_outline = 1;
      toggle_fps_limit = "F1";
      toggle_hud = "F2";
    };
  };
}
