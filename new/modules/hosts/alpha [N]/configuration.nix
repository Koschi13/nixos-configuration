{
  self,
  inputs,
  lib,
  pkgs,
  ...
}: let
  # TODO: use this
  # desktop = "sway";
in {
  flake.modules = lib.mkMerge [
    (self.factory.luks "alpha" "8e424358-602c-490d-9a00-ad3d00108f32" true)
    (self.factory.greetd "max" "${pkgs.sway}/bin/sway")
    {
      nixos.alpha = {
        imports = with inputs.self.modules.nixos; [
          system-desktop

          # TODO: import here or through configurations (e.g.: system or other collection types)?
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
