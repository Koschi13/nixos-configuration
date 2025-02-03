{
  config,
  lib,
  pkgs,
  ...
}:

{
  services.kanshi = {
    enable = true;

    settings = [
      {
        profile = {
          name = "alpha";
          outputs = [
            {
              criteria = "AOC U34G2G4R3 0x00002347";
              position = "0,0";
              mode = "3440x1440@60Hz";
            }
            {
              criteria = "Acer Technologies XF270HU T78EE0048521";
              position = "3440,-448";
              transform = "270";
              mode = "2560x1440@60Hz";
            }
          ];
        };
      }
      {
        profile = {
          name = "epsilon-homeoffice";
          outputs = [
            {
              criteria = "AOC U34G2G4R3 0x00002347";
              position = "1440,0";
              mode = "3440x1440@30Hz";
            }
            {
              criteria = "eDP-1";
              position = "0,0";
              mode = "2880x1800@90Hz";
              scale = 2.0;
            }
          ];
        };
      }
      {
        profile = {
          name = "epsilon";
          outputs = [
            {
              criteria = "eDP-1";
              position = "0,0";
              mode = "2880x1800@90Hz";
              scale = 1.5;
            }
          ];
        };
      }
    ];
  };
}
