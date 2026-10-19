{
  self,
  lib,
  ...
}: let
  hostname = "epsilon";
in {
  flake.modules = lib.mkMerge [
    # Setup luks
    (self.factory.luks {
      inherit hostname;
      uuid = "d28414c3-c27c-4fcd-8e88-551a2aa67a71";
      ssd = true;
    })
    # Make max the "default" user by assigning it as the default login to sway
    (self.factory.greetd {
      inherit hostname;
      username = "max";
      windowManager = "sway";
    })
    {
      nixos.epsilon = {
        imports = with self.modules.nixos; [
          system-desktop

          bluetooth
        ];

        networking = {
          hostName = hostname;
        };

        powerManagement.cpuFreqGovernor = "powersave";
      };
    }
  ];
}
