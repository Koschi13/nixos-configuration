{
  self,
  inputs,
  lib,
  pkgs,
  ...
}: let
  # TODO: use this
  # desktop = "sway";
  hostname = "alpha";
in {
  flake.modules = lib.mkMerge [
    # Setup luks
    (self.factory.luks hostname "8e424358-602c-490d-9a00-ad3d00108f32" true)
    # Make max the "default" user by assigning it as the default login to sway
    (self.factory.greetd "max" "${pkgs.sway}/bin/sway")
    (self.factory.virtualisation hostname ["max"] "amd")
    {
      nixos.alpha = {
        imports = with inputs.self.modules.nixos; [
          system-desktop

          # TODO: import here or through configurations (e.g.: system or other collection types)?
          bluetooth
          logind
          sway
          cachix

          amdgpu
          gaming
        ];

        networking = {
          hostName = hostname;
        };
      };
    }
  ];
}
