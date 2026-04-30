{
  self,
  inputs,
  lib,
  ...
}: {
  flake.modules = lib.mkMerge [
    (self.factory.luks "alpha" "8e424358-602c-490d-9a00-ad3d00108f32")
    {
      nixos.alpha = {
        imports = with inputs.self.modules.nixos; [
          bluetooth
          graphics
        ];
      };
    }
  ];
}
