{...}: {
  services.kanshi = {
    enable = true;

    settings = [
      {
        profile = {
          name = "alpha";
          outputs = [
            {
              criteria = "AOC U34G2G4R3 0x00002347";
              position = "1440,0";
              mode = "3440x1440@144.001Hz";
            }
            {
              criteria = "Acer Technologies XF270HU T78EE0048521";
              position = "0,-670";
              transform = "90";
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
              criteria = "AOC U34G2G4R3 0x00002347";
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
