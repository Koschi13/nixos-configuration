{...}: let
  acer = "Acer Technologies XF270HU T78EE0048521";
  aoc = "AOC U34G2G4R3 0x00002347";
in {
  services.kanshi = {
    enable = true;

    settings = [
      {
        profile = {
          name = "alpha";
          outputs = [
            {
              criteria = aoc;
              position = "2560,0";
              mode = "3440x1440@99.98Hz";
            }
            {
              criteria = acer;
              position = "0,0";
              mode = "2560x1440@143.856Hz";
            }
          ];
        };
      }
      {
        profile = {
          name = "epsilon-homeoffice";
          outputs = [
            {
              criteria = aoc;
              position = "1440,0";
              mode = "3440x1440@99.982Hz";
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
