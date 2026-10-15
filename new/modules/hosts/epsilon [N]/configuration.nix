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
      host = hostname;
      uuid = "d28414c3-c27c-4fcd-8e88-551a2aa67a71";
      ssd = true;
    })
    # Make max the "default" user by assigning it as the default login to sway
    (self.factory.greetd hostname "max" "sway")
    {
      nixos.epsilon = {
        imports = with self.modules.nixos; [
          system-desktop

          bluetooth
          docker
        ];

        networking = {
          hostName = hostname;
        };

        powerManagement.cpuFreqGovernor = "powersave";
      };
    }
  ];
}
