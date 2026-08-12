{self, ...}: let
  terminal = "ghostty";
in {
  flake.modules.homeManager = {
    terminal = {
      imports = [self.modules.homeManager.${terminal}];

      home.sessionVariables = {
        TERMINAL = terminal;
      };
    };

    rofi = {pkgs, ...}: let
      pkg = pkgs.${terminal};
    in {
      programs.rofi.terminal = "${pkg}/bin/${terminal}";
    };
  };
}
