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
