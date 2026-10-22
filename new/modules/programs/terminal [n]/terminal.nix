{self, ...}: let
  # The only place naming the terminal. Its aspect has to share the name of
  # its package and binary.
  terminal = "ghostty";
  command = pkgs: "${pkgs.${terminal}}/bin/${terminal}";
in {
  flake.modules.homeManager = {
    terminal = {
      imports = [self.modules.homeManager.${terminal}];

      home.sessionVariables = {
        TERMINAL = terminal;
      };
    };

    rofi = {pkgs, ...}: {
      programs.rofi.settings.terminal = command pkgs;
    };

    sway = {pkgs, ...}: {
      wayland.windowManager.sway.config.terminal = command pkgs;
    };
  };
}
