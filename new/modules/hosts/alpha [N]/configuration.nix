{
  self,
  lib,
  ...
}: let
  hostname = "alpha";
in {
  flake.modules = lib.mkMerge [
    # Setup luks
    (self.factory.luks {
      inherit hostname;
      uuid = "8e424358-602c-490d-9a00-ad3d00108f32";
      ssd = true;
    })
    # Make max the "default" user by assigning it as the default login to sway
    (self.factory.greetd {
      inherit hostname;
      username = "max";
      windowManager = "sway";
    })
    {
      nixos.alpha = {
        imports = with self.modules.nixos; [
          system-desktop

          bluetooth
          cachix
          android
          gaming
          minecraft
          virtualisation

          amdgpu
          rgb
        ];

        networking = {
          hostName = hostname;
        };
      };
    }
  ];
}
