{
  self,
  inputs,
  lib,
  pkgs,
  ...
}: {
  flake.modules = lib.mkMerge [
    (self.factory.luks "alpha" "8e424358-602c-490d-9a00-ad3d00108f32")
    (self.factory.greetd "max" "${pkgs.sway}/bin/sway")
    {
      nixos.alpha = {
        imports = with inputs.self.modules.nixos; [
          bluetooth
          graphics
          logind
          sway
          cachix
        ];

        networking = {
          hostName = "alpha";
        };
      };
    }
  ];
}
