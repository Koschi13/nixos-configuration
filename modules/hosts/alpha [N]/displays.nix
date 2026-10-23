{
  flake.modules.nixos.alpha = {
    home-manager.sharedModules = [
      {
        services.kanshi.settings = [
          {
            profile = {
              name = "alpha";
              outputs = [
                {
                  criteria = "AOC U34G2G4R3 0x00002347";
                  position = "2560,0";
                  mode = "3440x1440@99.98Hz";
                }
                {
                  criteria = "Acer Technologies XF270HU T78EE0048521";
                  position = "0,0";
                  mode = "2560x1440@143.856Hz";
                }
              ];
            };
          }
        ];
      }
    ];
  };
}
