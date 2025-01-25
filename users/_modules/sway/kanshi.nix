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
    ];
  };
}
