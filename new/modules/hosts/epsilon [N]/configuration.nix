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
    {
      nixos.epsilon = {
        imports = with self.modules.nixos; [
          system-desktop

          bluetooth
        ];

        networking = {
          hostName = hostname;
        };

        # Notifications about the battery and the power supply
        home-manager.sharedModules = [{services.poweralertd.enable = true;}];

        powerManagement.cpuFreqGovernor = "powersave";
      };
    }
  ];
}
