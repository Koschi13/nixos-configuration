{
  self,
  inputs,
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
    # Log in to sway through the greeter
    (self.factory.greetd {
      inherit hostname;
      windowManager = "sway";
      # Same criteria as the kanshi profile in displays.nix
      primaryOutput = "AOC U34G2G4R3 0x00002347";
      # Kept in the git-crypt secrets for copyright reasons
      wallpaper = "${inputs.git-crypt-secrets}/greeter-wallpaper.jpg";
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
